#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    char password[32];
    char input[32];

    int tries = 0;
    int tries_left = 5;

    /*
        Специально записываем пароль так,
        чтобы в дизассемблере были видны
        DWORD-константы как в оригинале.
    */

    *(unsigned int*)&password[0] = 0x73736170; // "pass"
    *(unsigned int*)&password[4] = 0x64726F77; // "word"
    *(unsigned int*)&password[8] = 0x00333231; // "123"

    puts("welcome to my crack me");

    while (tries <= 5)
    {
        puts("-------------------------------------");
        printf("enter the password: ");

        scanf("%31s", input);

        if (strcmp(input, password) == 0)
        {
            puts("congrats you cracked the password");
            return 0;
        }
        else
        {
            puts("wrong pass!!");

            tries_left = 5 - tries;

            printf("you got %d left\n", tries_left);

            if (tries_left == 0)
            {
                printf("you are out of guesses\n");
            }
        }

        tries++;
    }

    return 0;
}
