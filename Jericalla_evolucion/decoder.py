import re
import tkinter as tk
import tkinter.messagebox
import tkinter.filedialog

class App:
    selected_file: str | None = None
    instructions = {
        "add": {"opcode": 0b00, "args": 3},
        "sub": {"opcode": 0b01, "args": 3},
        "slt": {"opcode": 0b10, "args": 3},
        "sw": {"opcode": 0b11, "args": 2}
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
            for idx, line in enumerate(file):
                instruction = line.strip().split("#")[0]
                try:
                    res.append(self.parse_instruction(instruction))
                except ValueError as e:
                    tkinter.messagebox.showerror("Error", f"Error en la línea {idx + 1}: {e}")
                    return None
        return res

                
    def parse_instruction(self, instruction) -> str:
        regex = r'(\w+)\s+\$(\d+),?\s+\$(\d+)(?:,?\s+\$(\d+))?'
        match = re.match(regex, instruction)
        
        if not match:
            raise ValueError("Formato de instrucción no válido")
        
        instr, *regs = match.groups()
        regs = list(filter(None, regs))
        instr_lower = instr.lower()
        if instr_lower not in self.instructions:
            raise ValueError(f"Instrucción '{instr}' no válida")
        
        args = self.instructions[instr_lower]["args"]
        if args != len(regs):
            raise ValueError(f"Se esperaban {args} argumentos, pero se encontraron {len(regs)}")

        
        for reg in regs:
            if int(reg) < 0 or int(reg) > 31:
                raise ValueError(f"Registro ${reg} fuera de rango (0-31)")
        
        regs_str = "00000" if len(regs) == 2 else ""
        for reg in regs:
            regs_str += format(int(reg), '05b') 
        
        opcode = format(self.instructions[instr_lower]["opcode"], "02b")

        return f"{opcode}{regs_str}"
                           

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
            defaultextension=".txt",
            filetypes=[("Archivos de texto", "*.txt"), ("Todos los archivos", "*.*")]
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
