#pragma once
#include <string>

class MessageModel {
public:
    void setMessage(const std::string& newMessage);
    std::string getMessage() const;

private:
    std::string message = "Hello from Model";
};