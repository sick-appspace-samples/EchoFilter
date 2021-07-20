
--Start of Global Scope---------------------------------------------------------

local SCAN_FILE_PATH = "resources/main.xml"
print("Input File: ", SCAN_FILE_PATH)

-- Check for device capabilities
assert(Scan, "Scan not available, check capability of connected device")
assert(Scan.EchoFilter, "EchoFiler not available, check capability of connected device")

-- Create the filter
echoFilter = Scan.EchoFilter.create()
assert(echoFilter,"Error: EchoFilter could not be created")
Scan.EchoFilter.setType(echoFilter, "LAST")

-- Create provider. Providing starts automatically with the register call
-- which is found below the callback function
fileProvider = Scan.Provider.File.create()
assert(fileProvider,"Error: file driver could not created.")

-- Set the path
Scan.Provider.File.setFile(fileProvider, SCAN_FILE_PATH)
Scan.Provider.File.setDataSetID(fileProvider, 1)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

--------------------------------------------------------------------------------
-- Returns the number of beams and the number of non-zero distances of the given echo
--------------------------------------------------------------------------------
local function countNonZeroBeams(scan, iEcho)
  
  -- Get the beam and echo count of the scan read from file
  local beamCount = Scan.getBeamCount(scan)
  local echoCount = Scan.getEchoCount(scan)
  
  local nonzeroDistances = 0
  local fraction = 0.0

  -- Count the non-zero distances in the second echo of the input scan
  if ( iEcho <= echoCount ) then
    -- Note: the Lua table starts with 1
    local vDistance = Scan.toVector(scan, "DISTANCE", iEcho-1)
    for i=1, beamCount do
      if ( math.abs(vDistance[i]) > 0.01 ) then
        nonzeroDistances = nonzeroDistances + 1
      end
    end
    fraction = nonzeroDistances * 100.0 / beamCount
  end
  return beamCount, nonzeroDistances, fraction
end

----------------------------------------------------------------------------------
-- Compares the distances of two scans of the specified echo
----------------------------------------------------------------------------------
local function compareScans(inputScan, filteredScan, iEcho)
  
  -- Get the beam and echo counts
  local beamCountInput = Scan.getBeamCount(inputScan)
  local echoCountInput = Scan.getEchoCount(inputScan)
  local beamCountFiltered = Scan.getBeamCount(filteredScan)
  local echoCountFiltered = Scan.getEchoCount(filteredScan)
  
  -- Checks
  if ( iEcho <= echoCountInput and iEcho <= echoCountFiltered ) then
    if ( beamCountInput == beamCountFiltered ) then
      -- Note: The Lua tables start with 1.
      local vDistance1 = Scan.toVector(inputScan, "DISTANCE", iEcho-1)
      local vDistance2 = Scan.toVector(filteredScan, "DISTANCE", iEcho-1)
      -- Print beams with different distances
      print("The following beams have different distance values:")
      local count = 0
      for i=1, beamCountInput do
        local d1 = vDistance1[i]
        local d2 = vDistance2[i]
        if ( math.abs(d1-d2) > 0.01 ) then
          print(string.format("  beam %4d:  %10.2f -->  %10.2f", i, d1, d2))
          count = count + 1
        end
      end
      if ( count == 0 ) then
        print("  All distances are equal.")
      end
    end
  end
end

-------------------------------------------------------------------------------------
-- Is called for each new scan
-------------------------------------------------------------------------------------
local function handleOnNewScan(scan)

  local beamCountScan = Scan.getBeamCount(scan)
  local echoCountScan = Scan.getEchoCount(scan)
  local scanCounter = Scan.getNumber(scan)
  
  print(string.format("\nScan %d has %d beams with %d echos", scanCounter, beamCountScan, echoCountScan))
   
  -- Get number of beams and number of non-zeros of each echo
  for iEcho=1, echoCountScan do
    local beamCount, nonZeroDistances, fraction = countNonZeroBeams(scan, iEcho)
    print(string.format("Echo %4d has %4d non-zero echos (%5.1f %%)", iEcho, nonZeroDistances, fraction))
  end
  
  -- Clone input scan because the EchoFilter modifies the scan in place
  local inputScan = Scan.clone(scan)
  
   -- Extract the LAST non-zero echo from beams (the returned scan is a reference to the input scan)
  local filteredScan = Scan.EchoFilter.filter(echoFilter, scan)
  
  -- Get number of beams and number of non-zeros of the filtered scan
  local beamCount, nonZeroDistances, fraction = countNonZeroBeams(filteredScan, 1)
  print(string.format("The filtered scan has %d beams with %d non-zero echos (%5.1f %%)"
                      , beamCount, nonZeroDistances, fraction))
  
  -- Print differences of first echo
  compareScans(inputScan, filteredScan, 1)
end
-- Register callback function to "OnNewScan" event. 
-- This call also starts the playback of scans
Scan.Provider.File.register(fileProvider, "OnNewScan", handleOnNewScan)

--End of Function and Event Scope------------------------------------------------
