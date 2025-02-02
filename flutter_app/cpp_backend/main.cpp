#include "crow_all.h"
#include <vector>
#include <mutex>
#include <nlohmann/json.hpp> // For JSON handling

using json = nlohmann::json;

// Struct to hold vital signs data
struct VitalSigns
{
    int heartRate;
    int bloodPressure;
    int glucoseLevel;
};

// Global vector to store records and mutex for thread safety
std::vector<VitalSigns> records;
std::mutex mtx;

int main()
{
    crow::SimpleApp app;

    // Endpoint to add vital signs
    CROW_ROUTE(app, "/add")
        .methods("POST"_method)([](const crow::request &req)
                                {
        auto jsonData = json::parse(req.body);
        VitalSigns vs = { jsonData["heartRate"], jsonData["bloodPressure"], jsonData["glucoseLevel"] };

        {
            std::lock_guard<std::mutex> lock(mtx);
            records.push_back(vs);
        }

        return crow::response(200); });

    // Endpoint to get all records
    CROW_ROUTE(app, "/records")
        .methods("GET"_method)([](const crow::request &req)
                               {
        json result;
        {
            std::lock_guard<std::mutex> lock(mtx);
            for (const auto& record : records) {
                result.push_back({ {"heartRate", record.heartRate}, {"bloodPressure", record.bloodPressure}, {"glucoseLevel", record.glucoseLevel} });
            }
        }
        return crow::response{ result.dump() }; });

    // Start the server on port 18080
    app.port(18080).multithreaded().run();
}
