#ifndef SQUARE_H
#define SQUARE_H

class Square {
private:
    // checks if square is bomb or not
    bool isBomb;
    // checks if square has been revealed or not
    bool isRevealed;
    // checks if square has been flagged or not
    bool isFlagged;
    // number of adjacent bombs around a square
    int adjacentBombs;

public:
    // constructor for default square
    Square();

    // sets bombs surrounding a square 
    void setAdjacentBomb(int num);

    // returns the number of bombs surrounding a square 
    int getAdjacentBomb() const;

    // marks square as a bomb
    void setBomb();

    // reveals the square
    void reveal();

    // places or removes flag on a square
    void toggleFlag();

    // returns if a square has a bomb
    bool getIsBomb() const;

    // returns if square has already been revealed
    bool getIsRevealed() const;

    // returns if square has been flagged or not
    bool getIsFlagged() const;
};

#endif // SQUARE_H