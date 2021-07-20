/*
	Anthony Dalia
	an694448
	SneakyRooks
	Fall 2018
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>

#include "SneakyRooks.h"

int allTheRooksAreSafe(char **rookStrings, int numRooks, int boardSize)
{
	int i, row, col, rooksPresent;
	Coordinate **rookLocs;

	//Create one coordinate location for each rook
	rookLocs = malloc(sizeof(Coordinate*) * numRooks);

	//Run a parseing operation to populate the location of each rook into the array
	for (i = 0; i < numRooks; i++)
	{
		rookLocs[i] = malloc(sizeof(Coordinate));
		parseCoordinateString(rookStrings[i], (rookLocs[i]));
	}

	//Test for row collisions
	for(row = 1; row <= boardSize; row++)
	{
		rooksPresent = 0;

		for(i = 0; i < numRooks; i++)
		{
			if (rookLocs[i]->row == row)
			{
				rooksPresent++;
			}
		}

		if (rooksPresent > 1)
		{
			free(rookLocs);

			return 0; //Row Collision located
		}
	}

	//Test for col collisions
	for(col = 1; col <= boardSize; col++)
	{
		rooksPresent = 0;

		for(i = 0; i < numRooks; i++)
		{
			if (rookLocs[i]->col == col)
			{
				rooksPresent++;
			}
		}

		if (rooksPresent > 1)
		{
			free(rookLocs);
			return 0; //Collumn Collision Located
		}
	}

	//No rooks were found in collision so return 1
	free(rookLocs);
	return 1;

}

int customPow(int a, int b) //Had to create my own POW funciton to avoid using the -lm flag on compile :(
{
	//Base Case
	if (b == 0)
		return 1; //Anyhthing to the 0 power is 1

	//Recursive method for maximum possible percisison
	if (b%2 == 0)
	{
		return customPow(a,b/2)*customPow(a,b/2); //B is even so we dont need an extra a
	}
	else
	{
		return a*customPow(a,b/2)*customPow(a,b/2); //B is odd so we compensate with a one a offset
	}
}

void parseCoordinateString(char *rookString, Coordinate *rookCoordinate)
{

	int len, i=0, j=0, boardRow=0, boardCol=0, colLen;
	char *boardColStr, *boardRowStr;

	//Get the length of the string
	len = strlen(rookString);

	//Create a substring of max length for both components
	boardColStr = malloc(sizeof(char) * len);
	boardRowStr = malloc(sizeof(char) * len);

	//Parse the string for our colunm
	for (i = 0; i<len; i++)
	{
		if (isalpha(rookString[i]))
		{
			boardColStr[j] = rookString[i];
			j++;
		}
		else
		{
			break;
		}
	}

	colLen = strlen(boardColStr);

	//Convert each charecter to a number and then multiply them
	for (i=0; i<colLen; i++)
	{
		int convertedVal, stackedVal, expConst;

		expConst = colLen - (i+1);

		convertedVal = (boardColStr[i] - 'a') + 1;

		stackedVal = (customPow(26, expConst)*convertedVal);

		//Add the running total together
		boardCol += stackedVal;
	}

	//Reset j and contine the parsing to get the row
	j=0;
	for (; i<len; i++)
	{
		if (isalpha(rookString[i]))
		{
			return; //We recieved an invalid string so just get outa here
		}

		boardRowStr[j] = rookString[i];
		j++;
	}

	//Convert the row to an integer
	boardRow = atoi(boardRowStr);


	//Add the two values to the struct passed in
	rookCoordinate->col = boardCol;
	rookCoordinate->row = boardRow;

	//Free our allocated memmory
	free(boardColStr);
	free(boardRowStr);

	return;
}

double difficultyRating(void)
{
	return 1.0;
}

double hoursSpent(void)
{
	return 4.0;
}
