import tkinter as tk
from tkinter import scrolledtext
import pyttsx3
import threading

PSALMS = {
    "31편": "여호와여 내가 주께 피하오니 나를 영원히 부끄럽게 하지 마시고 주의 공의로 나를 건지소서. 내게 귀를 기울여 속히 건지시고 내게 견고한 바위와 구원하는 산성이 되소서.",
    "32편": "허물의 사함을 받고 자신의 죄가 가려진 자는 복이 있도다. 마음에 간사함이 없고 여호와께 정죄를 당하지 아니하는 자는 복이 있도다.",
    "33편": "너희 의인들아 여호와를 즐거워하라 찬송은 정직한 자들이 마땅히 할 바로다. 수금으로 여호와께 감사하고 열 줄 비파로 찬송할지어다."
}


class PsalmReaderApp:
    def __init__(self, root):
        self.root = root
        self.root.title("시편 읽어주는 앱 (31편 ~ 33편)")
        self.root.geometry("450x350")

        self.engine = pyttsx3.init()
        self.set_korean_voice()

        self.is_reading = False

        self.create_widgets()

    def set_korean_voice(self):
        voices = self.engine.getProperty('voices')
        for voice in voices:
            if 'ko' in voice.id or 'Korean' in voice.name:
                self.engine.setProperty('voice', voice.id)
                break
        self.engine.setProperty('rate', 150)

    def create_widgets(self):
        self.text_display = scrolledtext.ScrolledText(
            self.root, wrap=tk.WORD, width=50, height=10, font=("맑은 고딕", 11)
        )
        self.text_display.pack(pady=15, padx=15)
        self.text_display.insert(tk.END, "원하시는 시편 버튼을 클릭하세요.\n(텍스트가 여기에 표시되고 음성으로 읽어줍니다.)")
        self.text_display.config(state=tk.DISABLED)

        btn_frame = tk.Frame(self.root)
        btn_frame.pack(pady=10)

        tk.Button(btn_frame, text="시편 31편", command=lambda: self.play_psalm("31편"), width=10).grid(row=0, column=0, padx=5)
        tk.Button(btn_frame, text="시편 32편", command=lambda: self.play_psalm("32편"), width=10).grid(row=0, column=1, padx=5)
        tk.Button(btn_frame, text="시편 33편", command=lambda: self.play_psalm("33편"), width=10).grid(row=0, column=2, padx=5)

        tk.Button(self.root, text="읽기 정지", command=self.stop_reading, width=20, bg="#ffcccc").pack(pady=10)

    def play_psalm(self, chapter):
        self.stop_reading()

        text_to_read = PSALMS[chapter]

        self.text_display.config(state=tk.NORMAL)
        self.text_display.delete(1.0, tk.END)
        self.text_display.insert(tk.END, f"[{chapter}]\n\n{text_to_read}")
        self.text_display.config(state=tk.DISABLED)

        threading.Thread(target=self._read_text, args=(text_to_read,), daemon=True).start()

    def _read_text(self, text):
        self.is_reading = True
        self.engine.say(text)
        self.engine.runAndWait()
        self.is_reading = False

    def stop_reading(self):
        if self.is_reading:
            self.engine.stop()
            self.is_reading = False


if __name__ == "__main__":
    root = tk.Tk()
    app = PsalmReaderApp(root)
    root.mainloop()
