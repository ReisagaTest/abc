local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer

-- Function to send GET request to the API and get the Job ID
local function getJobIdFromApi()
    -- Send GET request to the API
    local response = http_request({
        Url = "http://145.223.81.79:2005/darkbeard",  -- API URL
        Method = "GET",  -- GET method
        Headers = {
            ["Content-Type"] = "application/json"  -- Header configuration if needed
        }
    })

    -- Check if the request was successful
    if response.StatusCode == 200 then
        -- Decode the JSON response into a Lua table
        local jsonResponse = HttpService:JSONDecode(response.Body)

        -- Get the 'content' field from the response (Job ID)
        local jobId = jsonResponse.content
        return jobId
    else
        print("Failed to get a valid response. Status code: " .. response.StatusCode)
        return nil
    end
end

-- Function to teleport to the server using Job ID
local function teleportToServerWithJobId()
    local jobId = getJobIdFromApi()
    
    if jobId then
        -- Get the Place ID of the game
        local placeId = game.PlaceId

        -- Teleport to the server with the Job ID
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        print("Teleporting to server with Job ID: " .. jobId)
    else
        print("No Job ID available to teleport.")
    end
end

-- Periodically request the API and execute the Job ID
while true do
    -- Call the teleport function to get Job ID and teleport
    teleportToServerWithJobId()
    
    -- Wait for 3 seconds before making the next API request
    wait(3)
end