#include "AppController.h"
#include <iostream>
using namespace std;

AppController::AppController(Game* g) {
    this->game = g;
}

void AppController::handleReveal(int row, int col) {
    cout << "Reveal at: (" << row << "," << col << ")" << endl;

    // On first click, place bombs safely around the clicked tile
    if (game->isFirstClick()) {
        game->getBoard().placeBombs(row, col);
        game->setFirstClick(false);
    }

    Board& board = game->getBoard();
    Square& sq = board.getSquare(row, col);

    // Don't do anything if already revealed or flagged
    if (sq.getIsRevealed() || sq.getIsFlagged()) return;

    board.revealTile(row, col);

    // Check loss — bomb reveal is handled one-by-one in MainWindow::updateUI
    if (sq.getIsBomb()) {
        game->endGame(true);
        return;
    }

    // Check win
    if (game->checkWin()) {
        game->endGame(false);
    }
}

void AppController::handleFlag(int row, int col) {
    cout << "Flag at (" << row << ", " << col << ")" << endl;

    Square& sq = game->getBoard().getSquare(row, col);
    if (sq.getIsRevealed()) return;

    game->getBoard().flagTile(row, col);
}

void AppController::startGame() {
    game->startGame();
}