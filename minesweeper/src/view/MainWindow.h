#pragma once
#include <QLabel>
#include <QMainWindow>
#include <QGridLayout>
#include <QPushButton>
#include <QStackedWidget>
#include <QWidget>
#include <QSoundEffect>
#include <vector>
#include "model/game.h"
#include "controller/AppController.h"

class MainWindow : public QMainWindow {
    Q_OBJECT

private:
    Game* game;
    AppController* controller;


    QStackedWidget* stackedWidget;
    QWidget* startPage;
    QWidget* difficultyPage;
    QWidget* gamePage;
    QWidget* gameOverPage;
    QLabel* flagLabel;

    QGridLayout* gridLayout;
    std::vector<std::vector<QPushButton*>> buttons;


    QSoundEffect* bgSound;
    QSoundEffect* firstClickSound;
    QSoundEffect* bombRevealSound;
    QSoundEffect* defeatSound;


    void setupStartPage();
    void setupDifficultyPage();
    void setupGameUI();
    void setupGameOverPage();
    void setupGrid();
    void connectButton(QPushButton* button, int row, int col);
    void updateUI();

public:
    MainWindow(Game* game, QWidget* parent = nullptr);
    ~MainWindow();
};