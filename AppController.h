#pragma once
#include "model/game.h"

class AppController {
private:
    Game* game;  

public:
    AppController(Game* g);

    void handleReveal(int row, int col);
    void handleFlag(int row, int col);
    void startGame();
};