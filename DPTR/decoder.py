import re
import tkinter as tk
import tkinter.messagebox
import tkinter.filedialog

class App:
    selected_file: str | None = None
    instr_format = {
        "r": {
            "pattern": re.compile(r"\w+\s+\$(?P<rd>\d+),?\s*\$(?P<rs>\d+),?\s+\$(?P<rt>\d+)"),
            "format": "{op:06b}{rs:05b}{rt:05b}{rd:05b}00000{fnc:06b}"
        },
        "i": {
            "pattern": re.compile(r"\w+\s+\$(?P<rt>\d+),?\s*\$(?P<rs>\d+),?\s+(?P<immediate>-?\d+)"),
            "format": "{op:06b}{rs:05b}{rt:05b}{immediate:016b}"
        },
        "i2": {
            "pattern": re.compile(r"\w+\s+\$(?P<rt>\d+),?\s*(?P<offset>-?\d+)\s*\(\s*\$(?P<base>\d+)\s*\)"),
            "format": "{op:06b}{base:05b}{rt:05b}{offset:016b}"
        },
        "j": {
            "pattern": re.compile(r"\w+\s+(?P<instr_index>\d+)"),
            "format": "{op:06b}{instr_index:026b}"
        },
        "nop": {
            "pattern": re.compile(r"\w+"),
            "format": "0" * 32
        }
    }

    instructions = {
        "add": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100000
        },
        "sub": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100010
        },
        "slt": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b101010
        },
        "or": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100101      
        },
        "and": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100100
        },
        "nop": {
            "instr_type": "nop",
        },
        "addi": {
            "instr_type": "i",
            "op": 0b001000
        },
        "andi": {
            "instr_type": "i",
            "op": 0b001100
        },
        "ori": {
            "instr_type": "i",
            "op": 0b001101
        },
        "slti": {
            "instr_type": "i",
            "op": 0b001010
        },
        "beq": {
            "instr_type": "i",
            "op": 0b000100
        },
        "sw": {
            "instr_type": "i2",
            "op": 0b101011
        },
        "lw": {
            "instr_type": "i2",
            "op": 0b100011
        },
        "j": {
            "instr_type": "j",
            "op": 0b000010
        }
    }

    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Decodificador de código ensamblador")
        self.root.geometry("400x200")

        select_button = tk.Button(self.root, text="Seleccionar archivo de código ensamblador", command=self.select_file)
        select_button.pack(pady=10)

        self.selected_file_label = tk.Label(self.root, text="Ningún archivo seleccionado", wraplength=350)
        self.selected_file_label.pack(pady=5)

        save_button = tk.Button(self.root, text="Guardar archivo binario", command=self.save_file)
        save_button.pack(pady=10)

        self.root.mainloop()


    def decode_file(self, file_path) -> list:
        res = []
        with open(file_path, 'r') as file:
            lines = file.readlines()
        try:
            for idx, line in enumerate(lines):
                    line = self.preprocess_line(line)
                    if not line: continue
                    bin_instr = self.parse_instruction(line)
                    res.append(
                        bin_instr[0:8] + " " +
                        bin_instr[8:16] + " " +
                        bin_instr[16:24] + " " +
                        bin_instr[24:32]
                    )
        except ValueError as e:
            tkinter.messagebox.showerror("Error", f"Error en la línea {idx + 1}: {e}")
            return None
        return res

    def register_alias(self, match) -> str:
        reg_alias = {
            "$zero": 0,
            "$at": 1,
            "$v0": 2,
            "$v1": 3,
            "$a0": 4,
            "$a1": 5,
            "$a2": 6,
            "$a3": 7,
            "$t0": 8,
            "$t1": 9,
            "$t2": 10,
            "$t3": 11,
            "$t4": 12,
            "$t5": 13,
            "$t6": 14,
            "$t7": 15,
            "$s0": 16,
            "$s1": 17,
            "$s2": 18,
            "$s3": 19,
            "$s4": 20,
            "$s5": 21,
            "$s6": 22,
            "$s7": 23,
            "$t8": 24,
            "$t9": 25,
            "$k0": 26,
            "$k1": 27,
            "$gp": 28,
            "$sp": 29,
            "$fp": 30,
            "$s8": 30,
            "$ra": 31
        }
        match = match.group(0)
        return "$" + str(reg_alias.get(match, match))


    def preprocess_line(self, line) -> str:
        line = line.strip().partition("#")[0]
        return re.sub(r"\$\w+\d?", self.register_alias, line)


    def parse_instruction(self, instruction) -> str:
        find_instr = r'(\w+).*'
        instr_match = re.match(find_instr, instruction)
        if not instr_match:
            raise ValueError("Formato de instrucción no válido")
        
        instr = instr_match.groups()[0]
        instr_lower = instr.lower()

        if instr_lower not in self.instructions:
            raise ValueError(f"Instrucción '{instr}' no válida")
        
        decode = self.instructions[instr_lower]
        instr_type = decode["instr_type"]
        instr_type = self.instr_format[instr_type]

        match = instr_type["pattern"].match(instruction)

        if not match:
            raise ValueError("Formato de instrucción no válido")
        
        groups = match.groupdict()
        for key in groups:
            number = int(groups[key])
            if number < 0:
                number = int.from_bytes(number.to_bytes(2, 'big', signed=True), 'big')
            groups[key] = number

        groups.update(decode)

        return instr_type["format"].format_map(groups)
                           

    def select_file(self):
        file_path = tkinter.filedialog.askopenfilename(
            title="Selecciona un archivo de código ensamblador",
            filetypes=[("Archivos de ensamblador", "*.asm")]
        )

        if file_path:
            self.selected_file_label.config(text=f"Archivo seleccionado: {file_path}")
            self.selected_file = file_path
        else:
            self.selected_file_label.config(text="Ningún archivo seleccionado")
            self.selected_file = None


    def save_file(self):
        if not self.selected_file:
            tkinter.messagebox.showerror("Error", "No se seleccionó ningún archivo.")
            return

        save_path = tkinter.filedialog.asksaveasfilename(
            title="Guardar como",
            defaultextension=".mem",
            filetypes=[("Archivos de memoria", "*.mem"), ("Archivos de texto", "*.txt"), ("Todos los archivos", "*.*")]
        )

        if not save_path:
            return
        
        result = self.decode_file(self.selected_file)
        if result is None: return

        try:
            with open(save_path, 'w') as outfile:
                if result: 
                    outfile.write(result[0])
                outfile.writelines('\n' + line for line in result[1:])
            tkinter.messagebox.showinfo("Guardado", "Archivo binario guardado exitosamente")
        except Exception as e:
            tkinter.messagebox.showerror("Error", f"Ocurrió un error: {e}")


if __name__ == "__main__":
    App()
