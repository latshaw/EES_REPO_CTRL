import os
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
def WritePinLineToFile(contents, File, PinName, PinList, DeclaredPins):
    if contents[1] == "0":
        assignment = "assign " + PinName + " = 1'bz; //Direction: Unused, High Impedance"
        File.append(assignment+"\n")
        PinList.append(PinName)
    else:
        if "Input" in contents[2]:
            assignment =  "assign " + contents[1] + " = " + PinName + "; //Direction: " + contents[2] + "\n"
            File.append(assignment)
            PinList.append(PinName)
            DeclaredPins += " " + contents[1] + ","
        elif "Output" in contents[2]:
            assignment = "assign " + PinName + " = " + contents[1] + "; //Direction: " + contents[2] + "\n"
            File.append(assignment)
            PinList.append(PinName)
            DeclaredPins += " " + contents[1] + ","
        else:
            print("Bad direction idenfier, skipping pin: " + contents[0])
    return DeclaredPins

def LAHADefinition(line, File, PinList, Connector, DeclaredPins):
        #Break each line into its components
        contents = line.split(',')
        #Check if pin is part of HPC or LPC connector
        if(int(contents[3]) > Connector):
            #Check if line is for the correct type of pin
            if (contents[0][0:2] == "LA") or  (contents[0][0:2] == "HA") or  (contents[0][0:2] == "HB"):
                #Create name for pin to be used
                PinName = "FMC" + str(i+1) + "_" + contents[0][0:2] + contents[0][4:6] + "[" + str(int(contents[0][2:4])) + "]"
                return WritePinLineToFile(contents, File, PinName, PinList, DeclaredPins)
            #print(line)
            else:
                return DeclaredPins
        else:
            return DeclaredPins

def UserClockDefinition(line, File, PinList, Connector, DeclaredPins):
        #Break each line into its components
        contents = line.split(',')
        #Check if pin is part of HPC or LPC connector
        if(int(contents[3]) > Connector):
            #Check if line is for the correct type of pin
            if contents[0][0:3] == ("CLK"):
                Name = contents[0].split("_")
                #Create name for pin to be used
                if len(Name) == 2:
                    PinName = "FMC" + str(i+1) + "_" + Name[0][0:3] + "_" + Name[1]
                else:
                    PinName = "FMC" + str(i+1) + "_" + Name[0][0:3] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][3])) + "]"
                return WritePinLineToFile(contents, File, PinName, PinList, DeclaredPins)
            #print(line)
            else:
                return DeclaredPins
        else:
            return DeclaredPins

def GigTXRXDefinition(line, File, PinList, Connector, DeclaredPins):
        #Break each line into its components
        contents = line.split(',')
        #Check if pin is part of HPC or LPC connector
        if(int(contents[3]) > Connector):
            #Check if line is for the correct type of pin
            if contents[0][0:2] == ("DP"):
                Name = contents[0].split("_")
                #Create name for pin to be used
                PinName = "FMC" + str(i+1) + "_" + Name[0][0:2] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][2])) + "]"
                return WritePinLineToFile(contents, File, PinName, PinList, DeclaredPins)
            #print(line)
            else:
                return DeclaredPins
        else:
            return DeclaredPins

def GigClockDefinition(line, File, PinList, Connector, DeclaredPins):
        #Break each line into its components
        contents = line.split(',')
        #Check if pin is part of HPC or LPC connector
        if(int(contents[3]) > Connector):
            #Check if line is for the correct type of pin
            if contents[0][0:2] == ("GB"):
                Name = contents[0].split("_")
                #Create name for pin to be used
                PinName = "FMC" + str(i+1) + "_" + Name[0][0:6] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][6])) +"]"
                return WritePinLineToFile(contents, File, PinName, PinList, DeclaredPins)
            #print(line)
            else:
                return DeclaredPins
        else:
            return DeclaredPins

def WriteFile(FileName, FPGAName, DeclaredPins, Body):
    FmcHeader = open(FileName + ".vh", "w")
    FmcHeader.write("//Declaring wires.\n")
    FmcHeader.write("wire" + DeclaredPins[:-1] + "\n")
    FmcHeader.write("//FMC pin mapping for " + FPGAName + " FPGA.\n")
    for i in Body:
        FmcHeader.write(i)
    FmcHeader.close()

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
while True:
    NumFMCHeaders = input("How many FMCs do you want to generate a header for? ")
    if NumFMCHeaders.isdigit():
        break
FPGAPart = input("Enter FPGA name, leave blank for '###': ")
if FPGAPart == "":
    FPGAPart = "###"
NumDefinitionFiles = int(NumFMCHeaders)
DefinitionFilePaths = []
HPCLPC = []
print("Definition file type should be '.csv,' eg ('Test.csv')")
for i in range(0, NumDefinitionFiles):
    DefinitionFilePaths.append(input("Type file name for definition file " + str(i+1) + " of " + str(NumDefinitionFiles) + ": "))
    while True:
        Choice = input("Is this a HPC or LPC connector? (HPC, LPC): ").upper()
        if Choice == "HPC" or Choice == "LPC":
            HPCLPC.append(Choice)
            break

#Reserving to add the ability to define gigabit transcevers and user clocks
DefineUserClocks = False
DefineMultiGigabitTranscever = False
DefineUserClocks = YesNoInput("Do you want to define user clocks?")
DefineMultiGigabitTranscever = YesNoInput("Do you want to define Multi-gigabit transcevers?")
UsedPins = []
WireNames = ""
PinDefinitions = []
for i in range(0, NumDefinitionFiles):
    #Open files
    Connector = -1
    DefinitionFile = open(DefinitionFilePaths[i], 'r')
    if HPCLPC[i] == "HPC":
        Connector = 0
    elif HPCLPC[i] == "LPC":
        Connector = 1
    #Get lines from the open file
    #lines = DefinitionFile.readlines()
    next(DefinitionFile)
    if (DefineUserClocks == False) and (DefineMultiGigabitTranscever == False):
        for line in DefinitionFile:
            WireNames = LAHADefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
    elif (DefineUserClocks == True) and (DefineMultiGigabitTranscever == False):
        for line in DefinitionFile:
            WireNames = LAHADefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
            WireNames = UserClockDefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
    elif (DefineUserClocks == False) and (DefineMultiGigabitTranscever == True):
        for line in DefinitionFile:
            WireNames = LAHADefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
            WireNames = GigTXRXDefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
            WireNames = GigClockDefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
    elif (DefineUserClocks == True) and (DefineMultiGigabitTranscever == True):
        for line in DefinitionFile:
            WireNames = LAHADefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
            WireNames = UserClockDefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
            WireNames = GigTXRXDefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
            WireNames = GigClockDefinition(line, PinDefinitions, UsedPins, Connector, WireNames)
    DefinitionFile.close()
WriteFile(OutputFileName, FPGAPart, WireNames, PinDefinitions)
if len(set(UsedPins)) < len(UsedPins):
    print(UsedPins)
    print("Duplicate pin found, aborting process.")
    os.remove(OutputFileName + ".vh")
    quit()
print("Done")
test = input()