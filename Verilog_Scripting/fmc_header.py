#Ask a yes or no question and return a true or false value with a valid input
def YesNoInput(Question):
    while True:
        Response = input(Question + " Y/N: ").upper()
        if Response == "Y":
            TrueFalse = True
            break
        elif Response == "N":
            TrueFalse = False
            break
    return TrueFalse

#Pin mapping syntax:
#used pins -> assign 'SIGNAL_NAME' = 'FMC_PORT';
#unused pins -> assign 'FMC_PORT' = "High Impeadance";
#High Impeadance = 1'bz

def LAHADefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        if contents[0][0:2] == ("LA" or  "HA"):
            if contents[1] == "0":
                assignment = "assign FMC" + str(i+1) + "_" + contents[0][0:2] + contents[0][4:6] + "[" + str(int(contents[0][2:4])) + "] = 1'bz; //Direction: Unused, High Impedance"
                File.write(assignment+"\n")
            else:
                if "Input" in contents[2]:
                    assignment =  "assign " +contents[1] + " = " +"FMC" + str(i+1) + "_" + contents[0][0:2] + contents[0][4:6] + "[" + str(int(contents[0][2:4])) +"]; //Direction: " + contents[2]
                    FmcHeader.write(assignment)
                elif "Output" in contents[2]:
                    assignment = "assign FMC" + str(i+1) + "_" + contents[0][0:2] + contents[0][4:6] + "[" + str(int(contents[0][2:4])) + "] = " + contents[1] +"; //Direction: " + contents[2]
                    File.write(assignment)
                else:
                    print("Bad direction idenfier, skipping pin: " + contents[0])
        #print(line)

def UserClockDefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        if contents[0][0:3] == ("CLK"):
            Name = contents[0].split("_")
            if contents[1] == "0":
                assignment = "assign FMC" + str(i+1) + "_" + Name[0][0:3] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][3])) + "] = 1'bz; //Direction: Unused, High Impedance"
                File.write(assignment+"\n")
            else:
                if "Input" in contents[2]:
                    assignment =  "assign " +contents[1] + " = " +"FMC" + str(i+1) + "_" + Name[0][0:3] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][3])) +"]; //Direction: " + contents[2]
                    FmcHeader.write(assignment)
                elif "Output" in contents[2]:
                    assignment = "assign FMC" + str(i+1) + "_" + Name[0][0:3] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][3])) + "] = " + contents[1] +"; //Direction: " + contents[2]
                    File.write(assignment)
                else:
                    print("Bad direction idenfier, skipping pin: " + contents[0])
        #print(line)

def GigTXRXDefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        if contents[0][0:2] == ("DP"):
            Name = contents[0].split("_")
            if contents[1] == "0":
                if contents[0][0:2] == ("DP"):
                    assignment = "assign FMC" + str(i+1) + "_" + Name[0][0:2] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][2])) + "] = 1'bz; //Direction: Unused, High Impedance"
                    File.write(assignment+"\n")
            else:
                if "Input" in contents[2]:
                    assignment =  "assign " +contents[1] + " = " +"FMC" + str(i+1) + "_" + Name[0][0:2] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][2])) +"]; //Direction: " + contents[2]
                    FmcHeader.write(assignment)
                elif "Output" in contents[2]:
                    assignment = "assign FMC" + str(i+1) + "_" + Name[0][0:2] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][2])) + "] = " + contents[1] +"; //Direction: " + contents[2]
                    File.write(assignment)
                else:
                    print("Bad direction idenfier, skipping pin: " + contents[0])
        #print(line)

def GigClockDefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        if contents[0][0:2] == ("GB"):
            Name = contents[0].split("_")
            if contents[1] == "0":
                assignment = "assign FMC" + str(i+1) + "_" + Name[0][0:6] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][6])) + "] = 1'bz; //Direction: Unused, High Impedance"
                File.write(assignment+"\n")
            else:
                if "Input" in contents[2]:
                    assignment =  "assign " +contents[1] + " = " +"FMC" + str(i+1) + "_" + Name[0][0:6] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][6])) +"]; //Direction: " + contents[2]
                    FmcHeader.write(assignment)
                elif "Output" in contents[2]:
                    assignment = "assign FMC" + str(i+1) + "_" + Name[0][0:6] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][6])) + "] = " + contents[1] +"; //Direction: " + contents[2]
                    File.write(assignment)
                else:
                    print("Bad direction idenfier, skipping pin: " + contents[0])
        #print(line)

OutputFileName = input("Enter output file name, leave field blank for default. EX. 'Test_File'\n")
InvalidInput = True
while InvalidInput:
    if " " in OutputFileName:
        InvalidInput = True
    elif "\\" in OutputFileName:
        InvalidInput = True
    elif "/" in OutputFileName:
        InvalidInput = True
    elif "." in OutputFileName:
        InvalidInput = True
    else:
        InvalidInput = False
        break
    OutputFileName = input("Invalid input.\nEnter output file name, leave field blank for default. EX. 'Test_File'\n")
if OutputFileName == "":
    OutputFileName = "fmc_pins"
FmcHeader = open(OutputFileName + ".vh", "w")
while True:
    NumFMCHeaders = input("How many FMCs do you want to generate a header for? ")
    if NumFMCHeaders.isdigit():
        break
FmcHeader.write("//FMC pin mapping for ### FPGA.\n")
NumDefinitionFiles = int(NumFMCHeaders)
DefinitionFilePaths = []
print(NumDefinitionFiles)
for i in range(0, NumDefinitionFiles):
    DefinitionFilePaths.append(input("Type file name for definition file " + str(i+1) + " of " + str(NumDefinitionFiles) + ": "))
#Reserving to add the ability to define gigabit transcevers and user clocks
DefineUserClocks = False
DefineMultiGigabitTranscever = False
DefineUserClocks = YesNoInput("Do you want to define user clocks?")
DefineMultiGigabitTranscever = YesNoInput("Do you want to define Multi-gigabit transcevers?")
for i in range(0, NumDefinitionFiles):
    #Open files
    DefinitionFile = open(DefinitionFilePaths[i], 'r')
    #Get lines from the open file
    lines = DefinitionFile.readlines()
    if (DefineUserClocks == False) and (DefineMultiGigabitTranscever == False):
        for line in lines:
            LAHADefinition(line, FmcHeader)
    elif (DefineUserClocks == True) and (DefineMultiGigabitTranscever == False):
        for line in lines:
            LAHADefinition(line, FmcHeader)
            UserClockDefinition(line, FmcHeader)
    elif (DefineUserClocks == False) and (DefineMultiGigabitTranscever == True):
        for line in lines:
            LAHADefinition(line, FmcHeader)
            GigTXRXDefinition(line, FmcHeader)
            GigClockDefinition(line, FmcHeader)
    elif (DefineUserClocks == True) and (DefineMultiGigabitTranscever == True):
        for line in lines:
            LAHADefinition(line, FmcHeader)
            UserClockDefinition(line, FmcHeader)
            GigTXRXDefinition(line, FmcHeader)
            GigClockDefinition(line, FmcHeader)
    DefinitionFile.close()
FmcHeader.close()
print("Done")
test = input()