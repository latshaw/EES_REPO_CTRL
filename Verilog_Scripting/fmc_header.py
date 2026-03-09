FmcHeader = open("fmc_pins.vh", "w")
while True:
    NumFMCHeaders = input("How many FMCs do you want to generate a header for?")
    if NumFMCHeaders.isdigit():
        break
FmcHeader.write("//FMC pin mapping for ### FPGA.\n")
NumDefinitionFiles = int(NumFMCHeaders)
DefinitionFilePaths = []
print(NumDefinitionFiles)
for i in range(0, NumDefinitionFiles):
    DefinitionFilePaths.append(input("Type file name for definition file " + str(i+1) + " of " + str(NumDefinitionFiles) + ": "))
for i in range(0, NumDefinitionFiles):
    #Open files
    DefinitionFile = open(DefinitionFilePaths[i], 'r')
    #Get lines from the open file
    lines = DefinitionFile.readlines()
    for line in lines:
        #Break each line into its components
        contents = line.split(',')
        if contents[1] == "0":
            if contents[0][0:2] == ("LA" or  "HA"):
                assignment = "assign FMC" + str(i+1) + "_" + contents[0][0:2] + contents[0][4:6] + "[" + str(int(contents[0][2:4])) + "] = 1'bz;"
                FmcHeader.write(assignment+"\n")
        else:
            if contents[0][0:2] == ("LA" or  "HA"):
                assignment = "assign FMC" + str(i+1) + "_" + contents[0][0:2] + contents[0][4:6] + "[" + str(int(contents[0][2:4])) + "] = " + contents[1] +"; //Direction: " + contents[2]
                FmcHeader.write(assignment)
        print(line)
    DefinitionFile.close()
#Pin mapping syntax:
#used pins -> assign 'SIGNAL_NAME' = 'FMC_PORT';
#unused pins -> assign 'FMC_PORT' = "High Impeadance";
#High Impeadance = 1'bz
FmcHeader.close()
test = input()