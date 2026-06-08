#ifndef GAME_H
#define GAME_H
#include <string>
#include "board.h"
#include "square.h"
 
class Game {
private:
    Board board;
    std::string gameState;
    std::string difficulty;
    bool firstClick;

    // History
    int currentHistoryIndex = 0;
 
public:
    // Constructor
    Game(std::string difficulty);
 
    // Methods
    void startGame();
    void resetGame();
    bool checkWin();
    void endGame(bool hitMine);
 

    bool isFirstClick() const;
    void setFirstClick(bool val);

    // Saving/Loading Game
    void saveToFile(const std::string& filePath) const;
    void loadFromFile(const std::string& filePath);

    // Getters
    std::string getGameState() const;
    Board& getBoard();
    std::string getDifficulty() const;
};
 
#endif
 