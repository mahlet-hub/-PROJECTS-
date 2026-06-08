#pragma once

#include <vector>
#include "square.h"
using namespace std;

class Board {
    private:
    vector<vector<Square>> grid;
        int rows;
        int cols;
        int numBombs;
        int numFlags;
        int flagsLeft;
    public:
        // Constructors
        Board();
        Board(int rows, int cols, int numBombs, int flagsLeft);

        // Places bombs on the board
        void placeBombs(int initRow, int initCol);

        // Computes adjacent bomb counts for non-bomb squares
        void calculateAdjBomb();

        // Getters
        int getRows() const;
        int getCols() const;
        int getNumBombs() const;
        int getFlagsLeft() const;
        int getNumFlags() const;
        void setNumFlags(int numFlags);

        // Counts bombs around a square
        int countAdjBombs(int row, int col) const;

        // Reveals a single tile
        void revealTile(int row, int col);

        // Toggles flag on a tile
        void flagTile(int row, int col);

        // Reveals adjacent blank/numbered squares
        void revealAdjBlanks(int row, int col);

        // Checks if a position is inside the board
        bool inBounds(int row, int col) const;

        Square& getSquare(int row, int col);
        const Square& getSquare(int row, int col) const;

};