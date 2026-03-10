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
def WritePinLineToFile(contents, File, PinName):
    if contents[1] == "0":
        assignment = "assign " + PinName + " = 1'bz; //Direction: Unused, High Impedance"
        File.write(assignment+"\n")
        return PinName
    else:
        if "Input" in contents[2]:
            assignment =  "assign " + contents[1] + " = " + PinName + "; //Direction: " + contents[2]
            File.write(assignment)
            return PinName
        elif "Output" in contents[2]:
            assignment = "assign " + PinName + " = " + contents[1] + "; //Direction: " + contents[2]
            File.write(assignment)
            return PinName
        else:
            print("Bad direction idenfier, skipping pin: " + contents[0])

def LAHADefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        #Check if line is for the correct type of pin
        if contents[0][0:2] == ("LA" or  "HA"):
            #Create name for pin to be used
            PinName = "FMC" + str(i+1) + "_" + contents[0][0:2] + contents[0][4:6] + "[" + str(int(contents[0][2:4])) + "]"
            return WritePinLineToFile(contents, File, PinName)
        #print(line)

def UserClockDefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        #Check if line is for the correct type of pin
        if contents[0][0:3] == ("CLK"):
            Name = contents[0].split("_")
            #Create name for pin to be used
            PinName = "FMC" + str(i+1) + "_" + Name[0][0:3] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][3])) + "]"
            return WritePinLineToFile(contents, File, PinName)
        #print(line)

def GigTXRXDefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        #Check if line is for the correct type of pin
        if contents[0][0:2] == ("DP"):
            Name = contents[0].split("_")
            #Create name for pin to be used
            PinName = "FMC" + str(i+1) + "_" + Name[0][0:2] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][2])) + "]"
            return WritePinLineToFile(contents, File, PinName)
        #print(line)

def GigClockDefinition(line, File):
        #Break each line into its components
        contents = line.split(',')
        #Check if line is for the correct type of pin
        if contents[0][0:2] == ("GB"):
            Name = contents[0].split("_")
            #Create name for pin to be used
            PinName = "FMC" + str(i+1) + "_" + Name[0][0:6] + "_" + Name[1] + "_" + Name[2] + "[" + str(int(Name[0][6])) +"]"
            return WritePinLineToFile(contents, File, PinName)
        #print(line)

def FindDuplicatePin(SearchPin, SearchList):
    for SearchTerm in SearchList:
                if SearchPin == SearchTerm:
                    print(SearchPin)
                    return True
    return False
            

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
    PinName = ""
    UsedPins = []
    DuplicatePin = False
    if (DefineUserClocks == False) and (DefineMultiGigabitTranscever == False):
        for line in lines:
            PinName = LAHADefinition(line, FmcHeader)
            if PinName != None:
                DuplicatePin = FindDuplicatePin(PinName, UsedPins)
                if DuplicatePin == True:
                        print("Duplicate pin found, aborting process.")
                        quit()
                elif DuplicatePin == False:
                    UsedPins.append(PinName)
                print("checked")
            print(PinName)
    elif (DefineUserClocks == True) and (DefineMultiGigabitTranscever == False):
        for line in lines:
            TempPinName0 = LAHADefinition(line, FmcHeader)
            TempPinName1 = UserClockDefinition(line, FmcHeader)
            if TempPinName0 != None:
                PinName = TempPinName0
            elif TempPinName1 != None:
                PinName = TempPinName1
            if (TempPinName0 != None) or (TempPinName1 != None):
                DuplicatePin = FindDuplicatePin(PinName, UsedPins)
                if DuplicatePin == True:
                        print("Duplicate pin found, aborting process.")
                        quit()
                elif DuplicatePin == False:
                    UsedPins.append(PinName)
                print("checked")
            print(PinName)
    elif (DefineUserClocks == False) and (DefineMultiGigabitTranscever == True):
        for line in lines:
            TempPinName0 = LAHADefinition(line, FmcHeader)
            TempPinName1 = GigTXRXDefinition(line, FmcHeader)
            TempPinName2 = GigClockDefinition(line, FmcHeader)
            if TempPinName0 != None:
                PinName = TempPinName0
            elif TempPinName1 != None:
                PinName = TempPinName1
            elif TempPinName2 != None:
                PinName = TempPinName2
            DuplicatePin = FindDuplicatePin(PinName, UsedPins)
            if (TempPinName0 != None) or (TempPinName1 != None) or (TempPinName2 != None):
                DuplicatePin = FindDuplicatePin(PinName, UsedPins)
                if DuplicatePin == True:
                        print("Duplicate pin found, aborting process.")
                        quit()
                elif DuplicatePin == False:
                    UsedPins.append(PinName)
                print("checked")
            print(PinName)
    elif (DefineUserClocks == True) and (DefineMultiGigabitTranscever == True):
        for line in lines:
            TempPinName0 = LAHADefinition(line, FmcHeader)
            TempPinName1 = UserClockDefinition(line, FmcHeader)
            TempPinName2 = GigTXRXDefinition(line, FmcHeader)
            TempPinName3 = GigClockDefinition(line, FmcHeader)
            if TempPinName0 != None:
                PinName = TempPinName0
            elif TempPinName1 != None:
                PinName = TempPinName1
            elif TempPinName2 != None:
                PinName = TempPinName2
            elif TempPinName3 != None:
                PinName = TempPinName3
            print(line)
            print(TempPinName0)
            print(TempPinName1)
            print(TempPinName2)
            print(TempPinName3)
            print(PinName)
            if (TempPinName0 != None) or (TempPinName1 != None) or (TempPinName2 != None) or (TempPinName3 != None):
                DuplicatePin = FindDuplicatePin(PinName, UsedPins)
                if DuplicatePin == True:
                        print("Duplicate pin found, aborting process.")
                        quit()
                elif DuplicatePin == False:
                    UsedPins.append(PinName)
                print("checked")
            print(PinName)
    DefinitionFile.close()
FmcHeader.close()
print("Done")
test = input()