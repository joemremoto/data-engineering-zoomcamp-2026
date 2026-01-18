from pathlib import Path

current_dir = Path.cwd()  # Gets the current working directory as a Path object
current_file = Path(__file__).name  # Gets the name of the current script file

print(f"Files in {current_dir}:")  # Prints the current directory path

for filepath in current_dir.iterdir():  # Loops through each item in the directory
    if filepath.name == current_file:
        continue  # Skips the script file itself

    print(f"  - {filepath.name}")  # Prints the name of each file/folder

    if filepath.is_file():
        content = filepath.read_text(encoding='utf-8')  # Reads file content as text
        print(f"    Content: {content}")  # Prints the content of the file