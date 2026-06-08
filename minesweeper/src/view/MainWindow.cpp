#include "MainWindow.h"
#include <QSoundEffect>
#include <QPixmap>
#include <QPainter>
#include <QMovie>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QMessageBox>
#include <QApplication>
#include <QTimer>
#include <QFileDialog>
#include <QDir>
#include <QCoreApplication>

MainWindow::MainWindow(Game* game, QWidget* parent)
    : QMainWindow(parent), game(game)
{
    controller = new AppController(game);

    bgSound = new QSoundEffect(this);
    bgSound->setSource(QUrl::fromLocalFile(":/src/view/start.wav"));
    bgSound->setLoopCount(1);
    bgSound->setVolume(1.0);

    QTimer::singleShot(200, [=]() {
        bgSound->play();
    });

    firstClickSound = new QSoundEffect(this);
    firstClickSound->setSource(QUrl::fromLocalFile(":/src/view/firstclick.wav"));
    firstClickSound->setVolume(0.8);


    bombRevealSound = new QSoundEffect(this);
    bombRevealSound->setSource(QUrl::fromLocalFile(":/src/view/bombsound.wav"));
    bombRevealSound->setVolume(0.8);


    defeatSound = new QSoundEffect(this);
    defeatSound->setSource(QUrl::fromLocalFile(":/src/view/defeat.wav"));
    defeatSound->setVolume(1.0);

    stackedWidget = new QStackedWidget(this);
    setCentralWidget(stackedWidget);

    setupStartPage();
    setupDifficultyPage();
    setupGameUI();
    setupGameOverPage();

    stackedWidget->addWidget(startPage);
    stackedWidget->addWidget(difficultyPage);
    stackedWidget->addWidget(gamePage);
    stackedWidget->addWidget(gameOverPage);

    stackedWidget->setCurrentWidget(startPage);

    setFixedSize(700, 800);
}

MainWindow::~MainWindow() {
    delete controller;
}


void MainWindow::setupStartPage() {
    startPage = new QWidget();

    QVBoxLayout* layout = new QVBoxLayout();
    layout->setContentsMargins(30, 60, 30, 30);
    layout->setSpacing(40);

    QLabel* title = new QLabel("M 🚩NESWEEPER");
    title->setAlignment(Qt::AlignCenter);
    title->setStyleSheet(R"(
        font-size: 48px;
        font-weight: 900;
        color: black;
        font-family: 'Courier New', 'Lucida Console', monospace;
        letter-spacing: 4px;
        text-transform: uppercase;
    )");

    QPushButton* startBtn = new QPushButton("START");
    startBtn->setFixedSize(220, 70);

    startBtn->setStyleSheet(R"(
        QPushButton {
            background-color: #98fb98;
            border-top: 4px solid #d4ffd4;
            border-left: 4px solid #d4ffd4;
            border-right: 4px solid #2a2a2a;
            border-bottom: 4px solid #2a2a2a;
            border-radius: 0px;
            color: black;
            font-family: 'Courier New', 'Lucida Console', monospace;
            font-size: 22px;
            font-weight: bold;
            letter-spacing: 3px;
            padding: 10px;
        }
        QPushButton:hover {
            background-color: #aafdaa;
        }
        QPushButton:pressed {
            background-color: #7ed67e;
            border-top: 4px solid #2a2a2a;
            border-left: 4px solid #2a2a2a;
            border-right: 4px solid #d4ffd4;
            border-bottom: 4px solid #d4ffd4;
            padding-top: 14px;
            padding-left: 14px;
        }
    )");
    QWidget* animContainer = new QWidget();
animContainer->setStyleSheet("background: transparent;");

QLabel* imageLabel = new QLabel(animContainer);  
QMovie* movie = new QMovie(":/src/view/bomb-3.gif");
movie->setScaledSize(QSize(100, 100));

imageLabel->setMovie(movie);
imageLabel->setFixedSize(100, 100);


int* xPos = new int(350);
imageLabel->move(*xPos, 370);

movie->start();

QTimer* walkTimer = new QTimer(this);
connect(walkTimer, &QTimer::timeout, [=]() {
    *xPos -= 3;

    if (*xPos < -300) {
        walkTimer->stop();
        return;
    }

    imageLabel->move(*xPos, 370);
});

walkTimer->start(16);

    QLabel* groundLabel = new QLabel();
    QPixmap ground(":/src/view/marioground.png");
    groundLabel->setPixmap(ground.scaled(720, ground.height(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation));
    groundLabel->setFixedSize(720, ground.height());
    groundLabel->setContentsMargins(0, 0, 50, 0);


    layout->addWidget(title, 0, Qt::AlignCenter);
    layout->addWidget(startBtn, 0, Qt::AlignCenter);
    layout->addStretch();
    layout->addWidget(groundLabel);
    layout->addWidget(imageLabel, 0, Qt::AlignCenter);
    

    startPage->setStyleSheet("background-color: #87CEEB;");
    startPage->setLayout(layout);

    connect(startBtn, &QPushButton::clicked, [=]() {
        stackedWidget->setCurrentWidget(difficultyPage);
    });
}

//
// ===== DIFFICULTY PAGE =====
//
void MainWindow::setupDifficultyPage() {
    difficultyPage = new QWidget();

    QVBoxLayout* layout = new QVBoxLayout();
    layout->setAlignment(Qt::AlignCenter);
    layout->setSpacing(25);

    QLabel* title = new QLabel("Select Difficulty");
    title->setAlignment(Qt::AlignCenter);
    title->setStyleSheet(R"(
        font-size: 36px;
        font-weight: bold;
        color: black;
        font-family: 'Courier New', 'Lucida Console', monospace;
        letter-spacing: 3px;
    )");
    layout->addWidget(title);

    QPushButton* easyBtn = new QPushButton("Easy");
    QPushButton* mediumBtn = new QPushButton("Medium");
    QPushButton* hardBtn = new QPushButton("Hard");

    QList<QPushButton*> btns = {easyBtn, mediumBtn, hardBtn};

    for (auto btn : btns) {
        btn->setFixedSize(220, 60);
        btn->setStyleSheet(R"(
            QPushButton {
                background-color: #C3B1E1;
                border-top: 4px solid #e0d4f7;
                border-left: 4px solid #e0d4f7;
                border-right: 4px solid #2a2a2a;
                border-bottom: 4px solid #2a2a2a;
                border-radius: 0px;
                color: black;
                font-family: 'Courier New', 'Lucida Console', monospace;
                font-size: 20px;
                font-weight: bold;
                letter-spacing: 2px;
                padding: 8px;
            }
            QPushButton:hover {
                background-color: #d0bff0;
            }
            QPushButton:pressed {
                background-color: #a88cd6;
                border-top: 4px solid #2a2a2a;
                border-left: 4px solid #2a2a2a;
                border-right: 4px solid #e0d4f7;
                border-bottom: 4px solid #e0d4f7;
                padding-top: 12px;
                padding-left: 12px;
            }
        )");
        layout->addWidget(btn, 0, Qt::AlignCenter);
    }

    difficultyPage->setStyleSheet("background-color: #E6D6FF;");
    difficultyPage->setLayout(layout);

    connect(easyBtn, &QPushButton::clicked, [=]() {
        game = new Game("easy");
        controller = new AppController(game);
        setupGrid();
        updateUI();
        stackedWidget->setCurrentWidget(gamePage);
    });

    connect(mediumBtn, &QPushButton::clicked, [=]() {
        game = new Game("medium");
        controller = new AppController(game);
        setupGrid();
        updateUI();
        stackedWidget->setCurrentWidget(gamePage);
    });

    connect(hardBtn, &QPushButton::clicked, [=]() {
        game = new Game("hard");
        controller = new AppController(game);
        setupGrid();
        updateUI();
        stackedWidget->setCurrentWidget(gamePage);
    });
}

//
// ===== GAME PAGE =====
//
void MainWindow::setupGameUI() {
    gamePage = new QWidget();

    QVBoxLayout* outerLayout = new QVBoxLayout();
    outerLayout->setSpacing(20);

    QLabel* title = new QLabel("M 🚩NESWEEPER");
    title->setAlignment(Qt::AlignCenter);
    title->setStyleSheet(R"(
        font-size: 42px;
        font-weight: bold;
        color: black;
        font-family: 'Courier New', 'Lucida Console', monospace;
        letter-spacing: 4px;
    )");
    outerLayout->addWidget(title);

    int flagsR = game->getBoard().getFlagsLeft();
    flagLabel = new QLabel(QString::fromStdString("🚩"+std::to_string(flagsR)));
    flagLabel->setAlignment(Qt::AlignRight);
    flagLabel->setStyleSheet(R"(
        font-size: 25px;
        font-weight: bold;
        color: black;
        font-family: 'Courier New', 'Lucida Console', monospace;
        letter-spacing: 4px;
    )");
    outerLayout->addWidget(flagLabel);

    QWidget* gridContainer = new QWidget();
    gridLayout = new QGridLayout();
    gridLayout->setSpacing(4);
    gridContainer->setLayout(gridLayout);
    outerLayout->addWidget(gridContainer);

    QPushButton* backBtn = new QPushButton("Back");
    backBtn->setFixedSize(150, 50);
    backBtn->setStyleSheet(R"(
        QPushButton {
            background-color: #C3B1E1;
            border-top: 4px solid #e0d4f7;
            border-left: 4px solid #e0d4f7;
            border-right: 4px solid #2a2a2a;
            border-bottom: 4px solid #2a2a2a;
            border-radius: 0px;
            color: black;
            font-family: 'Courier New', 'Lucida Console', monospace;
            font-size: 16px;
            font-weight: bold;
            letter-spacing: 2px;
            padding: 6px;
        }
        QPushButton:hover {
            background-color: #d0bff0;
        }
        QPushButton:pressed {
            background-color: #a88cd6;
            border-top: 4px solid #2a2a2a;
            border-left: 4px solid #2a2a2a;
            border-right: 4px solid #e0d4f7;
            border-bottom: 4px solid #e0d4f7;
            padding-top: 10px;
            padding-left: 10px;
        }
    )");

    connect(backBtn, &QPushButton::clicked, [=]() {
        stackedWidget->setCurrentWidget(difficultyPage);
    });

    QPushButton* saveBtn = new QPushButton("Save");
    saveBtn->setFixedSize(150, 50);
    saveBtn->setStyleSheet(R"(
        QPushButton {
            background-color: #C3B1E1;
            border-top: 4px solid #e0d4f7;
            border-left: 4px solid #e0d4f7;
            border-right: 4px solid #2a2a2a;
            border-bottom: 4px solid #2a2a2a;
            border-radius: 0px;
            color: black;
            font-family: 'Courier New', 'Lucida Console', monospace;
            font-size: 16px;
            font-weight: bold;
            letter-spacing: 2px;
            padding: 6px;
        }
        QPushButton:hover {
            background-color: #d0bff0;
        }
        QPushButton:pressed {
            background-color: #a88cd6;
            border-top: 4px solid #2a2a2a;
            border-left: 4px solid #2a2a2a;
            border-right: 4px solid #e0d4f7;
            border-bottom: 4px solid #e0d4f7;
            padding-top: 10px;
            padding-left: 10px;
        }
    )");

    connect(saveBtn, &QPushButton::clicked, [=]() {
        QString saveFolder = QCoreApplication::applicationDirPath() + "/../SavedGames";
        QDir().mkpath(saveFolder);
        QString saveFile = QFileDialog::getSaveFileName(this, "Save Game", saveFolder + "/minesweeper_save.sav", "Minesweeper Saves (*.sav);;All Files (*)");
        if (saveFile.isEmpty()) return;

        try {
            game->saveToFile(saveFile.toStdString());
            QMessageBox::information(this, "Save Successful", "Your game was saved to:\n" + saveFile);
        } catch (const std::exception& e) {
            QMessageBox::warning(this, "Save Failed", e.what());
        }
    });

    QPushButton* loadBtn = new QPushButton("Load");
    loadBtn->setFixedSize(150, 50);
    loadBtn->setStyleSheet(R"(
        QPushButton {
            background-color: #C3B1E1;
            border-top: 4px solid #e0d4f7;
            border-left: 4px solid #e0d4f7;
            border-right: 4px solid #2a2a2a;
            border-bottom: 4px solid #2a2a2a;
            border-radius: 0px;
            color: black;
            font-family: 'Courier New', 'Lucida Console', monospace;
            font-size: 16px;
            font-weight: bold;
            letter-spacing: 2px;
            padding: 6px;
        }
        QPushButton:hover {
            background-color: #d0bff0;
        }
        QPushButton:pressed {
            background-color: #a88cd6;
            border-top: 4px solid #2a2a2a;
            border-left: 4px solid #2a2a2a;
            border-right: 4px solid #e0d4f7;
            border-bottom: 4px solid #e0d4f7;
            padding-top: 10px;
            padding-left: 10px;
        }
    )");

    connect(loadBtn, &QPushButton::clicked, [=]() {
        QString saveFolder = QCoreApplication::applicationDirPath() + "/../SavedGames";
        QString loadFile = QFileDialog::getOpenFileName(this, "Load Game", saveFolder, "Minesweeper Saves (*.sav);;All Files (*)");
        if (loadFile.isEmpty()) return;

        try {
            Game* newGame = new Game("easy"); // dummy difficulty, will be overwritten
            newGame->loadFromFile(loadFile.toStdString());

            // Clean up old game and controller
            delete controller;
            delete game;

            game = newGame;
            controller = new AppController(game);

            // Recreate the grid for the new board size
            setupGrid();
            updateUI();

            //we can incllude this if we want... it is smoother gameplay w/o it tho
            //QMessageBox::information(this, "Load Successful", "Game loaded from:\n" + loadFile);
        } catch (const std::exception& e) {
            QMessageBox::warning(this, "Load Failed", e.what());
        }
    });

    outerLayout->addWidget(backBtn, 0, Qt::AlignCenter);
    outerLayout->addWidget(saveBtn, 0, Qt::AlignCenter);
    outerLayout->addWidget(loadBtn, 0, Qt::AlignCenter);

    gamePage->setStyleSheet("background-color: #E6D6FF;");
    gamePage->setLayout(outerLayout);
}


void MainWindow::setupGrid() {
    QLayoutItem* item;
    while ((item = gridLayout->takeAt(0)) != nullptr) {
        delete item->widget();
        delete item;
    }

    int rows = game->getBoard().getRows();
    int cols = game->getBoard().getCols();

    string diff = game->getDifficulty();

    buttons.clear();
    buttons.resize(rows, std::vector<QPushButton*>(cols));

    int size = 0;
    if(diff == "easy") {
        size = 60;
    } else if (diff == "medium") {
        size = 27;
    } else {
        size = 20;
    }
    //if(difficulty == easy) { int size = 60}
    //else if (difficulty == medium) { int size == 30} 
    //else {int size = 20}
    //int size = 20;

    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            QPushButton* button = new QPushButton();
            button->setFixedSize(size, size);
            button->setStyleSheet(R"(
                QPushButton {
                    background-color: #C3B1E1;
                    border-top: 3px solid #e0d4f7;
                    border-left: 3px solid #e0d4f7;
                    border-right: 3px solid #2a2a2a;
                    border-bottom: 3px solid #2a2a2a;
                    border-radius: 0px;
                    font-size: 20px;
                    color: #1a1a1a;
                }
                QPushButton:hover {
                    background-color: #d0bff0;
                }
                QPushButton:pressed {
                    background-color: #a88cd6;
                    border-top: 3px solid #2a2a2a;
                    border-left: 3px solid #2a2a2a;
                    border-right: 3px solid #e0d4f7;
                    border-bottom: 3px solid #e0d4f7;
                }
                QPushButton:disabled {
                    background-color: #b8a8d8;
                    border: 2px solid #6a5a8a;
                    color: #1a1a1a;
                }
            )");

            gridLayout->addWidget(button, r, c);
            buttons[r][c] = button;

            connectButton(button, r, c);
        }
    }
}

void MainWindow::connectButton(QPushButton* button, int row, int col) {
    connect(button, &QPushButton::clicked, [=]() {
        bool wasFirst = game->isFirstClick();
        controller->handleReveal(row, col);
        if (wasFirst) firstClickSound->play();
        updateUI();
    });

    button->setContextMenuPolicy(Qt::CustomContextMenu);

    connect(button, &QPushButton::customContextMenuRequested, [=](const QPoint &pos) {
        Q_UNUSED(pos);
        controller->handleFlag(row, col);
        updateUI();
    });
}


void MainWindow::setupGameOverPage() {
    gameOverPage = new QWidget();
    gameOverPage->setStyleSheet("background-color: #E6D6FF;");

    QVBoxLayout* layout = new QVBoxLayout();
    layout->setAlignment(Qt::AlignCenter);
    layout->setSpacing(40);

    QLabel* bombLabel = new QLabel("💣");
    bombLabel->setAlignment(Qt::AlignCenter);
    bombLabel->setStyleSheet("font-size: 80px;");

    QLabel* gameOverLabel = new QLabel("GAME OVER");
    gameOverLabel->setAlignment(Qt::AlignCenter);
    gameOverLabel->setStyleSheet(R"(
        font-size: 48px;
        font-weight: 900;
        color: black;
        font-family: 'Courier New', 'Lucida Console', monospace;
        letter-spacing: 4px;
    )");

    QPushButton* restartBtn = new QPushButton("MENU");
    restartBtn->setFixedSize(220, 70);
    restartBtn->setStyleSheet(R"(
        QPushButton {
            background-color: #98fb98;
            border-top: 4px solid #d4ffd4;
            border-left: 4px solid #d4ffd4;
            border-right: 4px solid #2a2a2a;
            border-bottom: 4px solid #2a2a2a;
            border-radius: 0px;
            color: black;
            font-family: 'Courier New', 'Lucida Console', monospace;
            font-size: 22px;
            font-weight: bold;
            letter-spacing: 3px;
            padding: 10px;
        }
        QPushButton:hover {
            background-color: #aafdaa;
        }
        QPushButton:pressed {
            background-color: #7ed67e;
            border-top: 4px solid #2a2a2a;
            border-left: 4px solid #2a2a2a;
            border-right: 4px solid #d4ffd4;
            border-bottom: 4px solid #d4ffd4;
            padding-top: 14px;
            padding-left: 14px;
        }
    )");

    connect(restartBtn, &QPushButton::clicked, [=]() {
        defeatSound->stop();
        bgSound->play();
        stackedWidget->setCurrentWidget(startPage);
    });

    layout->addWidget(bombLabel);
    layout->addWidget(gameOverLabel);
    layout->addWidget(restartBtn, 0, Qt::AlignCenter);

    gameOverPage->setLayout(layout);
}



void MainWindow::updateUI() {
    int rows = game->getBoard().getRows();
    int cols = game->getBoard().getCols();
    int flagsR = game->getBoard().getFlagsLeft();


    flagLabel->setText(QString::fromStdString("🚩"+std::to_string(flagsR)));


    static const QStringList bombColors = {
        "#4fc3f7", 
        "#26c6da",  
        "#fff176",  
        "#a5d6a7",  
        "#ffb74d"   
    };



    int bombColorIndex = 0;

    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            QPushButton* button = buttons[r][c];
            Square& square = game->getBoard().getSquare(r, c);

            if (square.getIsRevealed()) {
                if (square.getIsBomb()) {
                    
                    QString color = bombColors[bombColorIndex % bombColors.size()];
                    bombColorIndex++;
                    button->setText("💣");
                    button->setEnabled(false);
                    button->setStyleSheet(QString(R"(
                        QPushButton {
                            background-color: %1;
                            border: 2px solid #2a2a2a;
                            border-radius: 0px;
                            font-size: 20px;
                            text-align: top;
                            text-align: left;
                            
                        }
                        QPushButton:disabled {
                            background-color: %1;
                            border: 2px solid #2a2a2a;
                            color: #000000;
                        }
                    )").arg(color));
                } else {
                    int count = square.getAdjacentBomb();
                    button->setEnabled(false);
                    if (count > 0) {
                        button->setText(QString::number(count));
                        button->setStyleSheet(R"(
                            QPushButton {
                                background-color: #f48fb1;
                                border: 2px solid #2a2a2a;
                                border-radius: 0px;
                                font-size: 20px;
                                font-weight: bold;
                                color: #1a1a1a;
                                text-align: top;
                                text-align: left;
                            }
                            QPushButton:disabled {
                                background-color: #f48fb1;
                                border: 2px solid #2a2a2a;
                                color: #1a1a1a;
                            }
                        )");
                    } else {
                        // Light purple for blank tiles
                        button->setText("");
                        button->setStyleSheet(R"(
                            QPushButton {
                                background-color: #e1d5f5;
                                border: 2px solid #b39ddb;
                                border-radius: 0px;
                                font-size: 20px;
                                text-align: top;
                                text-align: left;
                            }
                            QPushButton:disabled {
                                background-color: #e1d5f5;
                                border: 2px solid #b39ddb;
                            }
                        )");
                    }
                }
            }
            else if (square.getIsFlagged()) {
                button->setText("🚩");
                button->setStyleSheet(QString(R"(
                    QPushButton {
                    background-color: #C3B1E1;
                    border-top: 3px solid #e0d4f7;
                    border-left: 3px solid #e0d4f7;
                    border-right: 3px solid #2a2a2a;
                    border-bottom: 3px solid #2a2a2a;
                    text-align: top;
                    text-align: left;
                            
                        }

                    )"));
            }
            else {
                button->setText("");
                button->setEnabled(true);
                button->setStyleSheet(QString(R"(
                QPushButton {
                background-color: #C3B1E1;
                border-top: 3px solid #e0d4f7;
                border-left: 3px solid #e0d4f7;
                border-right: 3px solid #2a2a2a;
                border-bottom: 3px solid #2a2a2a;
                text-align: top;
                text-align: left;
                            
                        }

                    )"));
            }
        }
    }
    int flagsQ = game->getBoard().getFlagsLeft();
    QLabel* flagCount = new QLabel(QString::fromStdString("🚩"+std::to_string(flagsQ)));
    flagCount->setAlignment(Qt::AlignRight);
    flagCount->setStyleSheet(R"(
        font-size: 25px;
        font-weight: bold;
        color: black;
        font-family: 'Courier New', 'Lucida Console', monospace;
        letter-spacing: 4px;
    )");
    std::string state = game->getGameState();

    if (state == "lost") {

        QList<QPair<int,int>> bombPositions;
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                Square& sq = game->getBoard().getSquare(r, c);
                if (sq.getIsBomb() && !sq.getIsRevealed()) {
                    bombPositions.append({r, c});
                }
            }
        }


        for (int r = 0; r < rows; r++)
            for (int c = 0; c < cols; c++)
                buttons[r][c]->setEnabled(false);


        static const QStringList bombColors = {
            "#4fc3f7", "#26c6da", "#fff176", "#a5d6a7", "#ffb74d"
        };

        for (int i = 0; i < bombPositions.size(); i++) {
            int r = bombPositions[i].first;
            int c = bombPositions[i].second;
            QString color = bombColors[i % bombColors.size()];
            QPushButton* btn = buttons[r][c];

            QTimer::singleShot(i * 300, [=]() {
                game->getBoard().getSquare(r, c).reveal();
                btn->setText("💣");
                btn->setStyleSheet(QString(R"(
                    QPushButton {
                        background-color: %1;
                        border: 2px solid #2a2a2a;
                        border-radius: 0px;
                        font-size: 20px;
                        text-align: top;
                        text-align: left;
                    }
                    QPushButton:disabled {
                        background-color: %1;
                        border: 2px solid #2a2a2a;
                        color: #000000;
                    }
                )").arg(color));
                bombRevealSound->play();
            });
        }


        int totalDelay = bombPositions.size() * 300 + 600;
        QTimer::singleShot(totalDelay, [=]() {
            bgSound->stop();
            defeatSound->play();
            stackedWidget->setCurrentWidget(gameOverPage);
        });
    }

    if (state == "won") {
        QMessageBox::information(this, "You Win!", "🎉 Congratulations!");
    }
}