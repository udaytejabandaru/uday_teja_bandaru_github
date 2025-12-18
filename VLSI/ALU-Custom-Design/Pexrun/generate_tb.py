#!/bin/python3

# USAGE: python3 generate_tb.py [template file]
# Will generate [template file].sp
# See my_tb.tpl for example template file
# If there are TPL commands left in your generated spice file, there was something wrong with the syntax of that line.
# Note that it is expected that GEN_VDD is used first and that parameters Tc and Di are defined.
# Email Ebenezer.Usih@utdallas.edu for assistance

import sys
import re

try:
    template_filename = sys.argv[1]
    #template_filename = 'tt.tpl'
    match = re.match("(^.+)\.tpl$", template_filename)
    if match:
        file_base_name = match[1]
    else:
        raise Exception("bad filename")
except:
    print("You must pass in a template file of format filename.tpl. Example Usage: ./generate_tb.py my_tb.tpl")
    exit(1)

print(template_filename)
# print(file_base_name)
spice_filename = file_base_name + '.sp'
print(spice_filename)

parameter_dict = {"VDD": "VDD!", "GND": "GND!", "VDD_VAL": "1.2v"}

with open(template_filename, 'r', encoding='utf-8') as template_file:
    with open(spice_filename, 'w', encoding='utf-8') as spice_file:
        print("$Generated from generate_tb.py", file=spice_file)
        template_line = template_file.readline()
        num_inputs = 0
        while template_line:
            template_line = template_line.replace('\n', '')
            write_line = template_line

            match = re.match("^\s*.param\s+(\S+)\s*=\s*(\S+)", template_line)
            if match:
                parameter_dict[match[1]] = match[2]

            match = re.match("^\s*TPL\s*GEN_VDD\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)(.*)$", template_line)
            if match:
                write_line = match[1] + " " + match[2] + " " + match[3] + " " + match[4] + match[5]
                parameter_dict["VDD"] = match[2]
                parameter_dict["GND"] = match[3]
                parameter_dict["VDD_VAL"] = match[4]

            match = re.match("^\s*TPL\s*GEN_RST\s+(\S+)(.*)$", template_line)
            if match:
                vdd = parameter_dict["VDD_VAL"]
                write_line = "v" + match[1] + " " + match[1] + " " + parameter_dict["GND"] + " PWL(0ps 0v 300ps 0v 350ps " + vdd + " 600ps " + vdd + " 650ps 0v)" + match[2]
                parameter_dict["RST"] = match[1]

            match = re.match("^\s*TPL\s*GEN_CLK\s+(\S+)(.*)$", template_line)
            if match:
                vdd = parameter_dict["VDD_VAL"]
                write_line = "v" + match[1] + " " + match[1] + " " + parameter_dict["GND"] + " PULSE(0v " + vdd + " 0ps 50ps 50ps 'Tc/2-50ps' Tc)" + match[2]
                parameter_dict["CLK"] = match[1]

            match = re.match("^\s*TPL\s*GEN_INP\s+(\S+)\s+(\S+)(.*)$", template_line)
            if match:
                vdd = parameter_dict["VDD_VAL"]
                values = match[2]
                num_inputs = max(num_inputs, len(values))
                write_line = "v" + match[1] + " " + match[1] + " " + parameter_dict["GND"] + " PWL(0ps 0v Di 0v"
                for i, v in enumerate(values):
                    if v == '0':
                        write_line = write_line + " 'Di+" + str(i) + "*Tc+50ps' 0v 'Di+" + str(i+1) + "*Tc' 0v"
                    if v == '1':
                        write_line = write_line + " 'Di+" + str(i) + "*Tc+50ps' " + vdd + " 'Di+" + str(i+1) + "*Tc' " + vdd
                    if v == 'x' or v == 'X':
                        write_line = write_line + " 'Di+" + str(i) + "*Tc+50ps' '" + vdd + "/2' 'Di+" + str(i+1) + "*Tc' '" + vdd + "/2'"
                write_line = write_line + ")" + match[3]

            match = re.match("^\s*TPL\s*GEN_RUN\s+(\S+)\s+(\S+)\s+([-+]?\d+)(.*)$", template_line)
            if match:
                num_inputs = num_inputs + int(match[3])
                write_line = match[1] + " " + match[2] + " '" + str(num_inputs) + "*Tc'" + match[4]

            print(write_line, file=spice_file)
            template_line = template_file.readline()

print(parameter_dict)
print("generate_tb.py concluded: have a good day!")

