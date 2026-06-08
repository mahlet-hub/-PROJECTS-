import random
import time
import math
from cs1graphics import *

flavor = input("Enter a flavor (chocolate, vanilla, pink): ")
icing_color = input("Ok what color icing do you want?: ")
age = int(input("Ok and how old are you?: "))
name = input("What's your name? ").strip().upper()

canvas = Canvas(600, 600, 'lightgray')

table_width = 400
table_height = 40
table_top_y = 440

table = Rectangle(table_width, table_height)
table.setFillColor('saddlebrown')
table.moveTo(300, table_top_y)
canvas.add(table)

leg_width = 20
leg_height = 80
leg_left = Rectangle(leg_width, leg_height)
leg_left.setFillColor('saddlebrown')
leg_left.moveTo(300 - table_width//2 + 30, table_top_y + leg_height//2 + table_height//2)
canvas.add(leg_left)

leg_right = Rectangle(leg_width, leg_height)
leg_right.setFillColor('saddlebrown')
leg_right.moveTo(300 + table_width//2 - 30, table_top_y + leg_height//2 + table_height//2)
canvas.add(leg_right)

flavor_colors = {'chocolate': 'brown', 'vanilla': 'white', 'pink': 'pink'}
layer_color = flavor_colors.get(flavor.lower(), 'white')

layer_heights = [60, 50, 40]
layer_widths = [300, 220, 150]

def add_cake_layer(center_x, center_y, width, height, flavor_color, icing_color):
    rect = Rectangle(width, height)
    rect.setFillColor(flavor_color)
    rect.moveTo(center_x, center_y)
    canvas.add(rect)
    
    ellipse = Ellipse(width, height//2)
    ellipse.setFillColor(flavor_color)
    ellipse.moveTo(center_x, center_y - height//2)
    canvas.add(ellipse)
    
    a = width / 2 - 10
    b = height / 4
    ball_diameter = 20
    perimeter = math.pi * (3*(a+b) - math.sqrt((3*a + b)*(a + 3*b)))  
    num_balls = int(perimeter / ball_diameter)
    
    for i in range(num_balls + 1):
        theta = math.pi * i / num_balls
        x = center_x + a * math.cos(theta)
        y = center_y - height/2 + b * math.sin(theta)
        ball = Circle(10)
        ball.setFillColor(icing_color)
        ball.moveTo(x, y)
        canvas.add(ball)

bottom_layer_y = table_top_y - table_height//2 - layer_heights[0]//2
center_y = bottom_layer_y
top_layer_center = 0
for i in range(3):
    add_cake_layer(300, center_y, layer_widths[i], layer_heights[i],
                   layer_color if i==0 else 'white', icing_color)
    if i==2:
        top_layer_center = center_y - layer_heights[i]//2
    center_y -= (layer_heights[i] - 10)

number_candle = Text(str(age), 24)
number_candle.setFontColor('purple')
number_candle.moveTo(300, top_layer_center - 20)
canvas.add(number_candle)

for _ in range(5):
    flame = Circle(5)
    flame.setFillColor(random.choice(['yellow','orange','gold']))
    flame.moveTo(300, top_layer_center - 40 + random.randint(-5,5))
    canvas.add(flame)

def add_banner(center_x, center_y, letter, color, width=35, height=45):
    tri = Polygon(
        Point(center_x - width//2, center_y),
        Point(center_x + width//2, center_y),
        Point(center_x, center_y + height)
    )
    tri.setFillColor(color)
    canvas.add(tri)
    
    txt = Text(letter, 18)
    txt.setFontColor('black')
    txt.moveTo(center_x, center_y + height//3)
    canvas.add(txt)

msg = f"HAPPY BIRTHDAY {name}!"
colors = ['purple','white']
start_x = 80
end_x = 520
num_letters = len(msg)
amplitude = 25
for i, letter in enumerate(msg):
    x = start_x + i * (end_x - start_x) / (num_letters - 1)
    y = 50 + amplitude * math.sin(math.pi * i / (num_letters - 1))
    add_banner(x, y, letter, colors[i % 2], width=35, height=45)
# Small note
note_width = 160
note_height = 80
note_x = 300
note_y = 450

note = Rectangle(note_width, note_height)
note.setFillColor('lightyellow')
note.setBorderColor('black')
note.setBorderWidth(2)
note.moveTo(note_x, note_y)
canvas.add(note)

note_text = Text("HAPPY BIRTHDAY\nI love you so much !", 12)
note_text.setFontColor('black')
note_text.moveTo(note_x, note_y)
canvas.add(note_text)

line = Path(Point(0,0), Point(62, 53))
line.setBorderColor('black')
line.setBorderWidth(2)
canvas.add(line)

line = Path(Point(600,0), Point(537, 54))
line.setBorderColor('black')
line.setBorderWidth(2)
canvas.add(line)

balloon = Circle(40)
balloon.moveTo(0, 280)
balloon.setFillColor('lightyellow')
canvas.add(balloon)

line = Path(Point(10,320), Point(125, 550))
line.setBorderColor('black')
line.setBorderWidth(2)
canvas.add(line)


balloon = Circle(40)
balloon.moveTo(100, 300)
balloon.setFillColor('purple')
canvas.add(balloon)

line = Path(Point(100,340), Point(125, 550))
line.setBorderColor('black')
line.setBorderWidth(2)
canvas.add(line)

balloon = Circle(40)
balloon.moveTo(75, 400)
balloon.setFillColor('pink')
canvas.add(balloon)

line = Path(Point(80,440), Point(125, 550))
line.setBorderColor('black')
line.setBorderWidth(2)
canvas.add(line)



def add_picture_frame_with_image(filename, x, y, frame_width=150, frame_height=90):
    frame = Rectangle(170, 110)
    frame.setFillColor("pink")
    frame.setBorderColor("black")
    frame.setBorderWidth(3)
    frame.moveTo(x, y)
    canvas.add(frame)
    
    img = Image(filename)
    scale_x = frame_width / img.getWidth()
    scale_y = frame_height / img.getHeight()
    scale = min(scale_x,scale_y)
    img.moveTo(x, y)
    canvas.add(img)

add_picture_frame_with_image(filename, 110, 190)



def add_picture_frame_with_image(filename, x, y, frame_width=150, frame_height=90):
    frame = Rectangle(170, 150)
    frame.setFillColor("lightyellow")
    frame.setBorderColor("black")
    frame.setBorderWidth(3)
    frame.moveTo(500, 270)
    canvas.add(frame)
    
    img = Image(filename)
    scale_x = frame_width / img.getWidth()
    scale_y = frame_height / img.getHeight()
    scale = min(scale_x,scale_y)
    img.moveTo(x, y)
    canvas.add(img)

add_picture_frame_with_image(filename, 500, 270)

confetti = []

for _ in range(100):
    x = random.randint(0, 600)
    y = 0
    size = random.randint(4, 8)
    color = random.choice(['red','yellow','blue','green','pink','purple','orange'])
    shape = Circle(size) if random.choice([True, False]) else Rectangle(size, size)
    shape.setFillColor(color)
    shape.setBorderWidth(0)
    shape.moveTo(x, y)
    canvas.add(shape)
    confetti.append({'shape': shape, 'x': x, 'y': y, 'speed': random.randint(15, 30)})

while True:
    for c in confetti:
        c['y'] += c['speed']
        if c['y'] > 600:
            c['y'] = 0
            c['x'] = random.randint(0, 600)
        c['shape'].moveTo(c['x'], c['y'])
    time.sleep(0.03)

