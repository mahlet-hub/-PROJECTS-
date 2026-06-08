#include "game.h"
#include <fstream>
#include <filesystem>
#include <stdexcept>
 
namespace fs = std::filesystem;
 
Game::Game(std::string difficulty) {
    this->difficulty = difficulty;
    gameState = "playing";
    firstClick = true;
 
    if (difficulty == "easy") {
        board = Board(9, 9, 10,10);
    } else if (difficulty == "medium") {
        board = Board(16, 16, 40,40);
    } else {
        board = Board(16, 30, 99,99);
    }
}

void Game::startGame() {
    gameState = "playing";
}
 
void Game::resetGame() {
    *this = Game(difficulty);
}
 
bool Game::checkWin() {
    int rows = board.getRows();
    int cols = board.getCols();
 
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            Square& sq = board.getSquare(r, c);
            
            if (!sq.getIsBomb() && !sq.getIsRevealed()) {
                return false;
            }
        }
    }
    return true;
}
 
void Game::endGame(bool hitMine) {
    gameState = hitMine ? "lost" : "won";
}
 
std::string Game::getGameState() const {
    return gameState;
}
 
Board& Game::getBoard() {
    return board;
}
 
std::string Game::getDifficulty() const {
    return difficulty;
}
 
bool Game::isFirstClick() const {
    return firstClick;
}
 
void Game::setFirstClick(bool val) {
    firstClick = val;
}

void Game::saveToFile(const std::string& filePath) const {
    fs::path path(filePath);
    if (path.has_parent_path()) {
        fs::create_directories(path.parent_path());
    }

    std::ofstream out(filePath);
    if (!out) {
        throw std::runtime_error("Unable to open save file for writing");
    }

    out << board.getRows() << ' ' << board.getCols() << ' ' << board.getNumBombs() << ' ';
    out << board.getNumFlags() << ' ' << currentHistoryIndex << ' ' << firstClick << ' ';
    out << gameState << ' ' << difficulty << '\n';

    for (int r = 0; r < board.getRows(); ++r) {
        for (int c = 0; c < board.getCols(); ++c) {
            const Square& sq = board.getSquare(r, c);
            out << sq.getIsBomb() << ' ' << sq.getIsRevealed() << ' ' << sq.getIsFlagged() << ' ' << sq.getAdjacentBomb() << '\n';
        }
    }
}

void Game::loadFromFile(const std::string& filePath) {
    std::ifstream in(filePath);
    if (!in) {
        throw std::runtime_error("Unable to open save file for reading");
    }

    int rows, cols, numBombs, numFlags;
    bool savedFirstClick;
    in >> rows >> cols >> numBombs >> numFlags >> currentHistoryIndex >> savedFirstClick >> gameState >> difficulty;

    board = Board(rows, cols, numBombs, numBombs - numFlags);
    board.setNumFlags(numFlags);
    firstClick = savedFirstClick;

    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            bool isBomb, isRevealed, isFlagged;
            int adjacentBombs;
            in >> isBomb >> isRevealed >> isFlagged >> adjacentBombs;
            Square& sq = board.getSquare(r, c);
            if (isBomb) sq.setBomb();
            sq.setAdjacentBomb(adjacentBombs);
            if (isFlagged) sq.toggleFlag();
            if (isRevealed) sq.reveal();
        }
    }
}
 