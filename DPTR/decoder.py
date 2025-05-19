import re
import tkinter as tk
import tkinter.messagebox
import tkinter.filedialog

class App:
    selected_file: str | None = None
    instr_format = {
        "r": {
            "pattern": re.compile(r"\w+\s+\$(?P<rd>\d+),?\s*\$(?P<rs>\d+),?\s+\$(?P<rt>\d+)"),
            "format": "000000{rs:05b}{rt:05b}{rd:05b}00000{fnc:06b}"
        },
        "i": {
            "pattern": re.compile(r"\w+\s+\$(?P<rt>\d+),?\s*\$(?P<rs>\d+),?\s+(?P<immediate>-?\d+|[a-zA-Z]\w*)"),
            "format": "{op:06b}{rs:05b}{rt:05b}{immediate:016b}"
        },
        "i2": {
            "pattern": re.compile(r"\w+\s+\$(?P<rt>\d+),?\s*(?P<offset>-?\d+)\s*\(\s*\$(?P<base>\d+)\s*\)"),
            "format": "{op:06b}{base:05b}{rt:05b}{offset:016b}"
        },
        "bgtz": {
            "pattern": re.compile(r"\w+\s+\$(?P<rs>\d+),?\s+(?P<immediate>-?\d+|[a-zA-Z]\w*)"),
            "format": "{op:06b}{rs:05b}00000{immediate:016b}"
        },
        "j": {
            "pattern": re.compile(r"\w+\s+(?P<instr_index>\d+|[a-zA-Z]\w*)"),
            "format": "{op:06b}{instr_index:026b}"
        },
        "shift": {
            "pattern": re.compile(r"\w+\s+\$(?P<rd>\d+),?\s*\$(?P<rt>\d+),?\s+(?P<shamt>\d+)"),
            "format": "0000000000{rotation:01b}{rt:05b}{rd:05b}{shamt:05b}{fnc:06b}"
        },
        "nop": {
            "pattern": re.compile(r"\w+"),
            "format": "0" * 32
        }
    }

    instructions = {
        "add": {
            "instr_type": "r",
            "fnc": 0b100000
        },
        "sub": {
            "instr_type": "r",
            "fnc": 0b100010
        },
        "slt": {
            "instr_type": "r",
            "fnc": 0b101010
        },
        "or": {
            "instr_type": "r",
            "fnc": 0b100101
        },
        "xor": {
            "instr_type": "r",
            "fnc": 0b100110
        },
        "and": {
            "instr_type": "r",
            "fnc": 0b100100
        },
        "sll": {
            "instr_type": "shift",
            "fnc": 0b000000,
            "rotation": 0b0
        },
        "srl": {
            "instr_type": "shift",
            "fnc": 0b000010,
            "rotation": 0b0
        },
        "rotr": {
            "instr_type": "shift",
            "fnc": 0b000010,
            "rotation": 0b1
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
        "xori": {
            "instr_type": "i",
            "op": 0b001110
        },
        "slti": {
            "instr_type": "i",
            "op": 0b001010
        },
        "beq": {
            "instr_type": "i",
            "op": 0b000100
        },
        "bne": {
            "instr_type": "i",
            "op": 0b000101
        },
        "bgtz": {
            "instr_type": "bgtz",
            "op": 0b000111
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
        self.root.geometry("500x400")

        section_title = tk.Label(self.root, text="Decodificador de código ensamblador", font=("Arial", 16))
        section_title.pack(pady=10)
        select_button = tk.Button(self.root, text="Seleccionar archivo de código ensamblador", command=self.select_file)
        select_button.pack(pady=10)

        self.selected_file_label = tk.Label(self.root, text="Ningún archivo seleccionado", wraplength=350)
        self.selected_file_label.pack(pady=10)

        save_button = tk.Button(self.root, text="Guardar archivo de instrucciones", command=self.save_file)
        save_button.pack(pady=10)

        section_title2 = tk.Label(self.root, text="Codificador datos de entrada", font=("Arial", 16))
        section_title2.pack(pady=(40, 5))
        text_entry = tk.Entry(self.root, width=50)
        text_entry.pack(pady=10)
        text_entry.insert(0, "Mensaje de entrada")
        text_entry.bind("<Return>", lambda event: self.save_data_file(text_entry.get()))

        save_data_button = tk.Button(self.root, text="Guardar archivo de datos", command=lambda: self.save_data_file(text_entry.get()))
        save_data_button.pack(pady=(10, 20))

        self.root.mainloop()

    def find_labels(self, lines):
        """Scan the code for labels and their positions"""
        labels = {}
        instr_count = 0
        
        for line in lines:
            line = line.strip().partition("#")[0]  # Remove comments
            if not line: continue
            
            label_match = re.match(r'([a-zA-Z]\w*):(?:\s*)(.*)', line)
            if label_match:
                label_name = label_match.group(1)
                labels[label_name] = instr_count
                
                # If there's an instruction on the same line after the label,
                # count it as an instruction
                if label_match.group(2).strip():
                    instr_count += 1
            else:
                instr_count += 1
                
        return labels

    def decode_file(self, file_path) -> list | None:
        res = []
        with open(file_path, 'r') as file:
            lines = file.readlines()
        
        labels = self.find_labels(lines)
        
        idx = 0
        try:
            instr_count = 0
            for idx, line in enumerate(lines):
                line = self.preprocess_line(line)
                if not line: continue
                
                # Extract instruction if line contains a label
                label_match = re.match(r'[a-zA-Z]\w*:(?:\s*)(.*)', line)
                if label_match:
                    instr = label_match.group(1).strip()
                    if not instr: continue  # Skip if there's only a label with no instruction
                    line = instr
                
                bin_instr = self.parse_instruction(line, instr_count, labels)
                res.append(
                    bin_instr[0:8] + " " +
                    bin_instr[8:16] + " " +
                    bin_instr[16:24] + " " +
                    bin_instr[24:32]
                )
                instr_count += 1
                
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

    def parse_instruction(self, instruction, current_pc, labels) -> str:
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
        
        # Handle labels for branch and jump instructions
        if instr_lower in {"beq", "bne", "bgtz"} and not str(groups["immediate"]).lstrip("-").isdigit():
            label = groups["immediate"]
            if label not in labels:
                raise ValueError(f"Label '{label}' no encontrada")
            
            # Calculate branch offset (label_address - pc - 1)
            offset = labels[label] - (current_pc + 1)
            groups["immediate"] = offset
            
        elif instr_lower in {"j"} and not str(groups["instr_index"]).isdigit():
            label = groups["instr_index"]
            if label not in labels:
                raise ValueError(f"Label '{label}' no encontrada")
            
            groups["instr_index"] = labels[label]
            
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
            tkinter.messagebox.showinfo("Guardado", "Archivo de instrucciones guardado exitosamente")
        except Exception as e:
            tkinter.messagebox.showerror("Error", f"Ocurrió un error: {e}")

    def save_data_file(self, text: str):
        save_path = tkinter.filedialog.asksaveasfilename(
            title="Guardar como",
            defaultextension=".mem",
            filetypes=[("Archivos de memoria", "*.mem"), ("Archivos de texto", "*.txt"), ("Todos los archivos", "*.*")]
        )

        if not save_path:
            return
        
        data = [
            # Initial hash values
            0x6a, 0x09, 0xe6, 0x67, 0xbb, 0x67, 0xae, 0x85,
            0x3c, 0x6e, 0xf3, 0x72, 0xa5, 0x4f, 0xf5, 0x3a,
            0x51, 0x0e, 0x52, 0x7f, 0x9b, 0x05, 0x68, 0x8c,
            0x1f, 0x83, 0xd9, 0xab, 0x5b, 0xe0, 0xcd, 0x19,

            # Constants
            0x42, 0x8a, 0x2f, 0x98, 0x71, 0x37, 0x44, 0x91,
            0xb5, 0xc0, 0xfb, 0xcf, 0xe9, 0xb5, 0xdb, 0xa5,
            0x39, 0x56, 0xc2, 0x5b, 0x59, 0xf1, 0x11, 0xf1,
            0x92, 0x3f, 0x82, 0xa4, 0xab, 0x1c, 0x5e, 0xd5,
            0xd8, 0x07, 0xaa, 0x98, 0x12, 0x83, 0x5b, 0x01,
            0x24, 0x31, 0x85, 0xbe, 0x55, 0x0c, 0x7d, 0xc3,
            0x72, 0xbe, 0x5d, 0x74, 0x80, 0xde, 0xb1, 0xfe,
            0x9b, 0xdc, 0x06, 0xa7, 0xc1, 0x9b, 0xf1, 0x74,
            0xe4, 0x9b, 0x69, 0xc1, 0xef, 0xbe, 0x47, 0x86,
            0x0f, 0xc1, 0x9d, 0xc6, 0x24, 0x0c, 0xa1, 0xcc,
            0x2d, 0xe9, 0x2c, 0x6f, 0x4a, 0x74, 0x84, 0xaa,
            0x5c, 0xb0, 0xa9, 0xdc, 0x76, 0xf9, 0x88, 0xda,
            0x98, 0x3e, 0x51, 0x52, 0xa8, 0x31, 0xc6, 0x6d,
            0xb0, 0x03, 0x27, 0xc8, 0xbf, 0x59, 0x7f, 0xc7,
            0xc6, 0xe0, 0x0b, 0xf3, 0xd5, 0xa7, 0x91, 0x47,
            0x06, 0xca, 0x63, 0x51, 0x14, 0x29, 0x29, 0x67,
            0x27, 0xb7, 0x0a, 0x85, 0x2e, 0x1b, 0x21, 0x38,
            0x4d, 0x2c, 0x6d, 0xfc, 0x53, 0x38, 0x0d, 0x13,
            0x65, 0x0a, 0x73, 0x54, 0x76, 0x6a, 0x0a, 0xbb,
            0x81, 0xc2, 0xc9, 0x2e, 0x92, 0x72, 0x2c, 0x85,
            0xa2, 0xbf, 0xe8, 0xa1, 0xa8, 0x1a, 0x66, 0x4b,
            0xc2, 0x4b, 0x8b, 0x70, 0xc7, 0x6c, 0x51, 0xa3,
            0xd1, 0x92, 0xe8, 0x19, 0xd6, 0x99, 0x06, 0x24,
            0xf4, 0x0e, 0x35, 0x85, 0x10, 0x6a, 0xa0, 0x70,
            0x19, 0xa4, 0xc1, 0x16, 0x1e, 0x37, 0x6c, 0x08,
            0x27, 0x48, 0x77, 0x4c, 0x34, 0xb0, 0xbc, 0xb5,
            0x39, 0x1c, 0x0c, 0xb3, 0x4e, 0xd8, 0xaa, 0x4a,
            0x5b, 0x9c, 0xca, 0x4f, 0x68, 0x2e, 0x6f, 0xf3,
            0x74, 0x8f, 0x82, 0xee, 0x78, 0xa5, 0x63, 0x6f,
            0x84, 0xc8, 0x78, 0x14, 0x8c, 0xc7, 0x02, 0x08,
            0x90, 0xbe, 0xff, 0xfa, 0xa4, 0x50, 0x6c, 0xeb,
            0xbe, 0xf9, 0xa3, 0xf7, 0xc6, 0x71, 0x78, 0xf2,
            
            # Chunk space
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        ]

        data.extend(text.encode('utf-8'))

        try:
            with open(save_path, 'w') as outfile:
                for b in data:
                    outfile.write(bin(b)[2:].zfill(8) + ' ')
                outfile.write('0' * 8)
            tkinter.messagebox.showinfo("Guardado", "Archivo de datos guardado exitosamente")
        except Exception as e:
            tkinter.messagebox.showerror("Error", f"Ocurrió un error: {e}")


if __name__ == "__main__":
    App()
