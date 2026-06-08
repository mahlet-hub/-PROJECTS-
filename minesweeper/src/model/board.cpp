#include "board.h"
#include <cstdlib>
#include <ctime>
 
Board::Board() : rows(0), cols(0), numBombs(0), numFlags(0), flagsLeft(0){}
 
Board::Board(int rows, int cols, int numBombs, int flagsLeft)
    : rows(rows), cols(cols), numBombs(numBombs), numFlags(0), flagsLeft(flagsLeft)
{
    // Initialize grid with default (empty) squares
    grid.resize(rows, std::vector<Square>(cols));
}
 
void Board::placeBombs(int initRow, int initCol) {
    srand(static_cast<unsigned int>(time(nullptr)));
 
    int placed = 0;
    while (placed < numBombs) {
        int r = rand() % rows;
        int c = rand() % cols;
 
        
        bool tooClose = (abs(r - initRow) <= 1 && abs(c - initCol) <= 1);
        if (!grid[r][c].getIsBomb() && !tooClose) {
            grid[r][c].setBomb();
            placed++;
        }
    }
 
    calculateAdjBomb();
}
 
void Board::calculateAdjBomb() {
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            if (!grid[r][c].getIsBomb()) {
                grid[r][c].setAdjacentBomb(countAdjBombs(r, c));
            }
        }
    }
}
 
int Board::getRows() const { return rows; }
int Board::getCols() const { return cols; }
int Board::getNumBombs() const { return numBombs; }
int Board::getFlagsLeft() const { return flagsLeft; }
int Board::getNumFlags() const { return numFlags; }
void Board::setNumFlags(int numFlags) { this->numFlags = numFlags; }
 
int Board::countAdjBombs(int row, int col) const {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = row + dr;
            int nc = col + dc;
            if (inBounds(nr, nc) && grid[nr][nc].getIsBomb()) {
                count++;
            }
        }
    }
    return count;
}
 
void Board::revealTile(int row, int col) {
    if (!inBounds(row, col)) return;
    Square& sq = grid[row][col];
    if (sq.getIsRevealed() || sq.getIsFlagged()) return;
 
    sq.reveal();
 
    // If no adjacent bombs, flood-fill reveal neighbors
    if (!sq.getIsBomb() && sq.getAdjacentBomb() == 0) {
        revealAdjBlanks(row, col);
    }
}
 
void Board::flagTile(int row, int col) {
    if (!inBounds(row, col)) return;
    Square& sq = grid[row][col];
    if (sq.getIsRevealed()) return;
    
    if (sq.getIsFlagged()) {
        sq.toggleFlag();
        numFlags--;
        flagsLeft++;
    } else {
        if (flagsLeft-1<0) return;
        sq.toggleFlag();
        flagsLeft--;
        numFlags++;
    }
}
 
void Board::revealAdjBlanks(int row, int col) {
    for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = row + dr;
            int nc = col + dc;
            if (!inBounds(nr, nc)) continue;
 
            Square& neighbor = grid[nr][nc];
            if (neighbor.getIsRevealed() || neighbor.getIsFlagged() || neighbor.getIsBomb()) continue;
 
            neighbor.reveal();
 
            
            if (neighbor.getAdjacentBomb() == 0) {
                revealAdjBlanks(nr, nc);
            }
        }
    }
}

bool Board::inBounds(int row, int col) const {
    return row >= 0 && row < rows && col >= 0 && col < cols;
}

Square& Board::getSquare(int row, int col) {
    return grid[row][col];
}

const Square& Board::getSquare(int row, int col) const {
    return grid[row][col];
}
