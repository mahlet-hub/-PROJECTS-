#include "model/MessageModel.h"

void MessageModel::setMessage(const std::string& newMessage) {
    message = newMessage;
}

std::string MessageModel::getMessage() const {
    return message;
}