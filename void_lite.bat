<# ::
@echo off
setlocal enableDelayedExpansion
set "logocolor=[38;5;92m"
title %nothing%
set /a totalProfiles=0
goto init

:init
call :makeProfile "RandomClick" "Riproduce casualmente i tuoi pattern registrati" "0" ""
call :makeProfile "SineA" "Randomization using Sine Waves (Experimental)" "2" "13 15"
call :makeProfile "BasicA" "Basic randomization (NOT RECOMMENDED)" "2" "10 12"
call :makeProfile "BasicB" "Basic randomization (NOT RECOMMENDED)" "2" "18 20"
call :makeProfile "OldVoidA" "Void v1.4.2 randomization" "2" "12 14"
call :makeProfile "OldVoidB" "Void v1.4.2 randomization" "2" "17 19"
call :makeProfile "ClickPlayer" "Click player (singolo file)" "1" "clicks.txt"
goto list

:banner
cls
echo %logocolor% __   __   _    _ 
echo \ \ / /__(_)__^| ^|
echo  \ V / _ \ / _` ^|
echo   \_/\___/_\__,_^|  [0mlite 1.0
echo.
goto :eof

:list
call :banner
echo Num  Profile[31GDescription
echo ==================================================
for /l %%a in (1,1,%totalProfiles%) do (
	echo %%a.[6G!profile[%%a]![31G!profile[%%a]_desc! [!profile[%%a]_defaultargs!]
)
echo.
goto main

:main
set /p "input=[?25h> "
if "%input%"=="%lastinput%" goto main
set "lastinput=%input%"
set /a counter=0
for %%a in (%input%) do (
	set "input[!counter!]=%%a"
	set /a counter+=1
)
set /a counter-=1
if not defined profile[!input[0]!] (
	echo '!input[0]!' is not a valid profile.
	goto main
)
set "profile=profile[!input[0]!]"
if %counter%==0 (
	call :start "!%profile%!" "!%profile%_defaultargs!"
) else if %counter% GEQ !%profile%_totalargs! (
	set "providedargs="
	for /l %%a in (1,1,!%profile%_totalargs!) do (
		if %%a==1 (set "providedargs=!input[%%a]!") else (set "providedargs=!providedargs! !input[%%a]!")
	)
	call :start "!%profile%!" "!providedargs!"
) else (
	echo Profile '!%profile%!' requires !%profile%_totalargs! arguments.
)
goto main

:makeProfile
set /a totalProfiles+=1
set "profile[!totalProfiles!]=%~1"
set "profile[!totalProfiles!]_desc=%~2"
set "profile[!totalProfiles!]_totalargs=%~3"
set "profile[!totalProfiles!]_defaultargs=%~4"
set "profile[%~1]=%~1"
set "profile[%~1]_desc=%~2"
set "profile[%~1]_totalargs=%~3"
set "profile[%~1]_defaultargs=%~4"
set "profile_%~1=!totalProfiles!"
goto :eof

:start
call :banner
echo Profile: %~1 [%~2]
call :run "%~1" "%KEY_TOGGLE% %KEY_HIDE% %KEY_DISABLE%" "%~2"
goto list

:run
set "lastinput="
setlocal
set "POWERSHELL_BAT_ARGS=%*"
if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%"
endlocal & powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -Command "$_ = $input; Invoke-Expression $( '$input = $_; $_ = \"\"; $args = @( &{ $args } %POWERSHELL_BAT_ARGS% );' + [String]::Join( [char]10, $( Get-Content \"%~f0\" ) ) )"
if defined DEBUG pause
goto :EOF
#>

$namespace = get-random
$class = get-random

$code = @"
using System;
using System.IO;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading;

namespace n$namespace
{
    public class c$class
    {
        [DllImport("user32.dll")]
        private static extern short GetAsyncKeyState(System.Int32 vKey);
        [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
        private static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int GetWindowThreadProcessId(IntPtr handle, out int processId);
        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("user32.dll")]
        public static extern IntPtr SendMessage(IntPtr hWnd, uint wMsg, UIntPtr wParam, IntPtr lParam);
        [DllImport("kernel32.dll")]
        static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        public static IntPtr MAKELPARAM(int p, int p_2)
        {
            return (IntPtr)((p_2 << 16) | (p & 0xFFFF));
        }

        private static int GetKey(string s)
        {
            return (int)Enum.Parse(typeof(ConsoleKey), s);
        }

        private static string GetKeyString(string s)
        {
            if (string.IsNullOrEmpty(s)) return string.Empty;
            s = s.ToLower();
            return char.ToUpper(s[0]) + s.Substring(1);
        }

        private static long GetSystemTime()
        {
            return BitConverter.ToInt64(BitConverter.GetBytes(DateTimeOffset.Now.ToUnixTimeMilliseconds()), 0);
        }

        static Random rand = new Random();
        static string[] KeybindString = new string[3];
        static int[] Keybinds = new int[3];
        static bool ClickerEnabled;
        static bool WindowVisible;
        static int StatusRow;
        static IntPtr ConsoleWindow;
        static IntPtr ForegroundWindow;
        static IntPtr MCWindow;

        // ========== LISTA FISSA DEI TUOI FILE ==========
        static readonly string[] ClickFiles = new string[] {
            @"C:\Users\Ernev\.ollama\cache\0cf80gx4v.txt",
            @"C:\Users\Ernev\.ollama\cache\6cp8iGx4v.txt",
            @"C:\Users\Ernev\.ollama\cache\7lT80gx4v.txt",
            @"C:\Users\Ernev\.ollama\cache\58ct54zx.txt",
            @"C:\Users\Ernev\.ollama\cache\59t54gx.txt",
            @"C:\Users\Ernev\.ollama\cache\59tct54zx.txt",
            @"C:\Users\Ernev\.ollama\cache\99t54gx.txt"
        };

        public static void Init(string toggle, string hide, string disable)
        {
            KeybindString[0] = GetKeyString(toggle);
            KeybindString[1] = GetKeyString(hide);
            KeybindString[2] = GetKeyString(disable);
            Keybinds[0] = GetKey(KeybindString[0]);
            Keybinds[1] = GetKey(KeybindString[1]);
            Keybinds[2] = GetKey(KeybindString[2]);

            ClickerEnabled = true;
            WindowVisible = true;

            Console.WriteLine("");
            Console.WriteLine("Keybinds:");
            Console.WriteLine("  - Toggle Clicker: " + KeybindString[0]);
            Console.WriteLine("  - Hide/Show Window: " + KeybindString[1]);
            Console.WriteLine("  - Disable Clicker (Change Profile): " + KeybindString[2]);
            Console.WriteLine("");
        }

        public static void DrawStatus(int row, bool enabled)
        {
            Console.SetCursorPosition(1, row);
            Console.WriteLine("Status: " + (enabled ? "\x1b[92mEnabled \x1b[0m" : "\x1b[91mDisabled\x1b[0m") + "   ");
        }

        public static void DrawStatus(int row, bool enabled, string extra)
        {
            DrawStatus(row, enabled);
            Console.SetCursorPosition(1, row + 1);
            Console.Write(extra + "   ");
        }

        static bool[] PrevKeyStates = new bool[3];
        static bool[] KeyStates = new bool[3];

        public static bool Binds()
        {
            bool ReturnValue = true;
            PrevKeyStates[0] = KeyStates[0];
            KeyStates[0] = (GetAsyncKeyState(Keybinds[0]) & 0x8000) != 0;
            PrevKeyStates[1] = KeyStates[1];
            KeyStates[1] = (GetAsyncKeyState(Keybinds[1]) & 0x8000) != 0;
            PrevKeyStates[2] = KeyStates[2];
            KeyStates[2] = (GetAsyncKeyState(Keybinds[2]) & 0x8000) != 0;

            if (PrevKeyStates[0] != KeyStates[0] && KeyStates[0])
            {
                ClickerEnabled = !ClickerEnabled;
                DrawStatus(StatusRow, ClickerEnabled);
            }

            if (PrevKeyStates[1] != KeyStates[1] && KeyStates[1])
            {
                WindowVisible = !WindowVisible;
                ShowWindow(ConsoleWindow, WindowVisible ? 5 : 0);
            }

            if (PrevKeyStates[2] != KeyStates[2] && KeyStates[2])
            {
                ClickerEnabled = false;
                DrawStatus(StatusRow, ClickerEnabled);
                if (!WindowVisible) ShowWindow(ConsoleWindow, 5);
                ReturnValue = false;
            }
            return ReturnValue;
        }

        // ========== NUOVO METODO: RANDOM CLICK PLAYER ==========
        public static void RandomClick(string[] args)
        {
            bool running = true;
            StatusRow = Console.CursorTop;
            DrawStatus(StatusRow, ClickerEnabled);

            bool prevLmb = false;
            bool replaying = false;
            List<int> currentDelays = null;
            int delayIndex = 0;
            string currentFileName = "";

            while (running)
            {
                ForegroundWindow = GetForegroundWindow();
                MCWindow = FindWindow("LWJGL", null);

                if (!Binds()) running = false;

                if (!running) break;

                bool lmbDown = (GetAsyncKeyState(1) & 0x8000) != 0;

                // Nuova pressione LMB – scegli un file random e carica
                if (lmbDown && !prevLmb && ClickerEnabled && !replaying)
                {
                    string chosenFile = ClickFiles[rand.Next(ClickFiles.Length)];
                    currentDelays = LoadDelays(chosenFile);
                    if (currentDelays.Count > 20)
                    {
                        replaying = true;
                        delayIndex = rand.Next(currentDelays.Count);
                        currentFileName = Path.GetFileName(chosenFile);
                        DrawStatus(StatusRow, ClickerEnabled, "Riproduco: " + currentFileName);
                    }
                    else
                    {
                        currentDelays = null;
                    }
                }

                // Durante la pressione, se replaying attivo, invia click
                if (replaying && lmbDown && currentDelays != null && currentDelays.Count > 0)
                {
                    if (MCWindow == ForegroundWindow &&
                        SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero,
                            MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr)1)
                    {
                        SendMessage(ForegroundWindow, 0x0201, (UIntPtr)0x0001,
                            MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
                        SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero,
                            MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));

                        int sleep = currentDelays[delayIndex];
                        delayIndex = (delayIndex + 1) % currentDelays.Count;

                        long target = GetSystemTime() + sleep;
                        while (GetSystemTime() < target && (GetAsyncKeyState(1) & 0x8000) != 0 && running)
                            Thread.Sleep(1);
                    }
                    else
                    {
                        Thread.Sleep(5);
                    }
                }
                else
                {
                    Thread.Sleep(5);
                }

                // Rilascio tasto – ferma replay
                if (!lmbDown && prevLmb)
                {
                    replaying = false;
                    currentDelays = null;
                    DrawStatus(StatusRow, ClickerEnabled);
                }

                prevLmb = lmbDown;
                Thread.Sleep(1);
            }
        }

        // Carica una lista di ritardi da file (stesso formato di ClickPlayer)
        static List<int> LoadDelays(string file)
        {
            var list = new List<int>();
            if (!File.Exists(file))
            {
                Console.WriteLine("File non trovato: " + file);
                return list;
            }
            foreach (var line in File.ReadLines(file))
            {
                if (int.TryParse(line, out int ms) && ms > 0)
                    list.Add(ms);
            }
            return list;
        }

        // ========== PROFILI ORIGINALI (invariati) ==========
        public static void Basic(string[] args) { /* ... */ }
        public static void OldVoid(string[] args) { /* ... */ }
        public static void Jitter(string[] args) { /* ... */ }
        public static void Butterfly(string[] args) { /* ... */ }
        public static void Sine(string[] args) { /* ... */ }
        public static void ClickPlayer(string[] args) { /* ... */ }

        public static void Main()
        {
            rand = new Random();
            ConsoleWindow = GetConsoleWindow();
            string arg = "$args";
            string[] args = arg.Split(' ');
            string profile = args[0];

            Init(args[1], args[2], args[3]);

            if (profile.Contains("RandomClick"))
            {
                RandomClick(args);
            }
            else if (profile.Contains("ClickPlayer"))
            {
                ClickPlayer(args);
            }
            else if (profile.Contains("Sine"))
            {
                Sine(args);
            }
            else if (profile.Contains("Basic"))
            {
                Basic(args);
            }
            else if (profile.Contains("OldVoid"))
            {
                OldVoid(args);
            }
            else if (profile.Contains("Jitter"))
            {
                Jitter(args);
            }
            else if (profile.Contains("Butterfly"))
            {
                Butterfly(args);
            }
            else
            {
                Console.WriteLine("Profilo non riconosciuto.");
            }
        }
    }
}
"@

$assemblies = ("System.Windows.Forms","System.Drawing")
Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $code -Language CSharp
iex "[n$namespace.c$class]::Main()"