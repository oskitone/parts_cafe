import csv
import pcbnew
import wx

def get_board(kicad_pcb_path):
    app = wx.App(False)
    wx.Log.SetLogLevel(wx.LOG_Warning) 

    return pcbnew.LoadBoard(kicad_pcb_path)

def get_footprints_from_pcb(kicad_pcb_path):
    data = {}
    board = get_board(kicad_pcb_path)

    for footprint in board.GetFootprints():
        ref = footprint.GetReference()
        position = footprint.GetPosition()

        data[ref] = {"x": position.x / 1000000, "y": position.y / 1000000}
    
    return data

def get_footprints_from_csv(csv_path):
    data = {}

    try:
        with open(csv_path, mode="r", encoding="utf-8") as file:
            reader = csv.reader(file)

            for row in reader:
                if not row: continue

                data[row[0]] = {
                    "x": float(row[1]),
                    "y": float(row[2])
                }

    except FileNotFoundError:
        print(f"Error: Reference CSV file '{csv_path}' not found.")
        exit(1)

    return data

def update_pcb_from_csv(kicad_pcb_path, input_csv_path):
    footprints_from_csv = get_footprints_from_csv(input_csv_path)

    board = get_board(kicad_pcb_path)

    for ref,props  in footprints_from_csv.items():
        print(f"Updating {ref}")

        footprint = board.FindFootprintByReference(ref)

        if footprint:
            old = footprint.GetPosition()

            new_x = int(props["x"] * 1000000)
            new_y = int(props["y"] * 1000000)

            if (old.x != new_x or old.y != new_y):
                print(f"  {old.x},{old.y} to {new_x},{new_y}")
                footprint.SetPosition(pcbnew.VECTOR2I(new_x, new_y))
            else:
                print(f"  No change")
        else:
            print(f"  Not found!")

    board.Save(kicad_pcb_path)

# kicad-python python/kicad_tinker.py > input.csv
# footprints_from_kicad = get_footprints_from_pcb("../guts/kicad/chordo/chordo.kicad_pcb")
# for ref,props  in footprints_from_kicad.items():
#     print(f"{ref},{props['x']},{props['y']}")

# footprints_from_csv = get_footprints_from_csv("input.csv")
# for ref,props  in footprints_from_csv.items():
#     print(f"{ref},{props['x']},{props['y']}")

update_pcb_from_csv(
    "../guts/kicad/chordo/chordo.kicad_pcb",
    "input.csv"
)