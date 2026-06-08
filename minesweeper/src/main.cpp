#include <QApplication>
#include "model/game.h"
#include "view/MainWindow.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    Game game("easy");
    game.startGame(); 

    MainWindow window(&game);
    window.show();

    return app.exec();
}