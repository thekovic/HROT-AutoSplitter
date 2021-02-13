state("HROT")
{
	int levelID : 0xEAF508;
	int gameIsRunning: 0xEAFAA0;
	int endScreen: 0xE7A630;
	int gameTimer: 0xE7C3F8;
	int mainMenuOFF: 0xE7C640;
}

start
{
	if (current.mainMenuOFF > old.mainMenuOFF) {
		print("RUN START");
		return true;
	}
}

split
{
	if (current.endScreen > old.endScreen) {
		return true;
	}
}

reset
{
	if (current.mainMenuOFF < old.mainMenuOFF && current.gameIsRunning != 1) {
		print("RUN RESET");
		return true;
	}
}

isLoading
{
	if (current.endScreen == 1) {
		return true;
	}
	else {
		return false;
	}
}

