state("HROT")
{
	int levelID : 0xEAF508;
	// int gameIsRunning: 0xEAFAA0;
	// int endScreen: 0xF48F20;
	int gameTimer: 0xE7C3F8;
	// int mainMenuOFF: 0xE7C640;
}

init
{
	ProcessModuleWow64Safe process = modules.FirstOrDefault(x => x.ModuleName.ToLower() == "hrot.exe");
	if (process == null)
    {
        Thread.Sleep(1000);
        print("process not loaded!");
                throw new Exception();
    }
	
	var TheScanner = new SignatureScanner(game, process.BaseAddress, process.ModuleMemorySize);
	
	var sig_gameIsRunning = new SigScanTarget(2, "C6 05 ?? ?? ?? ?? 01 83 7F ?? 00 0F 8E ?? ?? ?? ?? 80 3D ?? ?? ?? ?? 00 0F 85 ?? ?? ?? ?? 80 BB ?? ?? ?? ?? 00");
	sig_gameIsRunning.OnFound = (proc, scanner, ptr) => !proc.ReadPointer(ptr, out ptr) ? IntPtr.Zero : ptr;
	var sig_endScreen = new SigScanTarget(2, "80 3D ?? ?? ?? ?? 00 75 ?? 83 7F ?? 00");
	sig_endScreen.AddSignature(2, "C6 05 ?? ?? ?? ?? 01 33 C0 A0 ?? ?? ?? ??");
	sig_endScreen.OnFound = (proc, scanner, ptr) => !proc.ReadPointer(ptr, out ptr) ? IntPtr.Zero : ptr;
	var sig_mainMenuOFF = new SigScanTarget(2, "8B 2D ?? ?? ?? ?? A1 ?? ?? ?? ?? C7 40 ?? 00 00 56 42");
	sig_mainMenuOFF.OnFound = (proc, scanner, ptr) => !proc.ReadPointer(ptr, out ptr) ? IntPtr.Zero : proc.ReadPointer(ptr)+0x9C;

	IntPtr ptr_gameIsRunning = TheScanner.Scan(sig_gameIsRunning);
	// print(ptr_gameIsRunning.ToString("x"));
	IntPtr ptr_endScreen = TheScanner.Scan(sig_endScreen);
	// print(ptr_endScreen.ToString("x"));
	IntPtr ptr_mainMenuOFF = TheScanner.Scan(sig_mainMenuOFF);
	// print(ptr_mainMenuOFF.ToString("x"));
	
	vars.gameIsRunning = new MemoryWatcher<int>(ptr_gameIsRunning);
	vars.endScreen = new MemoryWatcher<int>(ptr_endScreen);
	vars.mainMenuOFF = new MemoryWatcher<int>(ptr_mainMenuOFF);
	
	vars.watchList = new MemoryWatcherList(){
		vars.gameIsRunning, vars.endScreen, vars.mainMenuOFF
	};
}

update
{
	vars.watchList.UpdateAll(game);
	
}

start
{
	if (vars.mainMenuOFF.Current > vars.mainMenuOFF.Old) {
		// print("RUN START");
		return true;
	}
}

split
{
	if (vars.endScreen.Current > vars.endScreen.Old) {
		return true;
	}
}

reset
{
	if (vars.mainMenuOFF.Current < vars.mainMenuOFF.Old && vars.gameIsRunning.Current != 1) {
		// print("RUN RESET");
		return true;
	}
}

isLoading
{
	if (vars.endScreen.Current == 1) {
		return true;
	}
	else {
		return false;
	}
}

