#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <time.h>
#include <semaphore.h>

// Pulse width in usec.  1/38kHz/2
#define PULSE_WIDTH 13
int send_low( int *pulses )
{
    int i;
    for( i = 0; i < 12; i++ )
    {
        pulses[i] = PULSE_WIDTH;
    }

    // Extend final pause to finish symbol
    pulses[i-1] += 10*PULSE_WIDTH*2;

    return i;
}

int send_high( int *pulses )
{
    int i;
    for( i = 0; i < 12; i++ )
    {
        pulses[i] = PULSE_WIDTH;
    }

    // Extend final pause to finish symbol
    pulses[i-1] += 21*PULSE_WIDTH*2;

    return i;
}

int send_start( int *pulses )
{
    int i;
    for( i = 0; i < 12; i++ )
    {
        pulses[i] = PULSE_WIDTH;
    }

    // Extend final pause to finish symbol
    pulses[i-1] += 39*PULSE_WIDTH*2;

    return i;
}

int send_stop( int *pulses )
{
    return send_start( pulses );
}

// Calculate and insert LRC check bits
// Send 16 bit word with start and stop
int send_word( int *pulses, int data )
{
    int i;
    int count;

    // Calculate check LRC bits
    int check = 0xf ^ ( data >> 12 ) ^ ( data >> 8 ) ^ ( data >> 4 );

    // Insert into data nibble 4
    data &= ~0xf;
    data |= check & 0xf;

printf( "send %04x\n", data );

    count = send_start( pulses );
    for( i = 0; i < 16; i++ )
    {
        if( data & 0x8000 ) count += send_high( &pulses[count] );
        else                count += send_low( &pulses[count] );

        data <<= 1;
    }
    count += send_stop( &pulses[count] );

    return( count );
}

int insert_channel_output( int data, int toggle, int channel, int output )
{
    // Insert toggle
    data |= ( toggle & 0x1 ) << 15;

    // Insert channel
    data |= ( channel & 0x3 ) << 12;

    // Insert output number
    data |= ( output & 0x1 ) << 8;

    return( data );
}

int send_brake( int *pulses, int toggle, int channel, int output )
{
    return send_word( pulses, insert_channel_output( 0x0480, toggle, channel, output ));
}

int send_increment_pwm( int *pulses, int toggle, int channel, int output )
{
    return send_word( pulses, insert_channel_output( 0x0640, toggle, channel, output ));
}

int send_decrement_pwm( int *pulses, int toggle, int channel, int output )
{
    return send_word( pulses, insert_channel_output( 0x0650, toggle, channel, output ));
}

int send_forward_pwm( int *pulses, int toggle, int channel, int output, int step )
{
    int command = 0x0400 | (( step & 0x7 ) << 4 );
    return send_word( pulses, insert_channel_output( command, toggle, channel, output ));
}

int send_reverse_pwm( int *pulses, int toggle, int channel, int output, int step )
{
    int command = 0x0480 | ((8 - ( step & 0x7 )) << 4 );
    return send_word( pulses, insert_channel_output( command, toggle, channel, output ));
}

int main( int argc, char **argv )
{
    int toggle = time(NULL);
    int channel = atoi(argv[1]);
    int output = atoi(argv[2]);
    int command = atoi(argv[3]);
    int speed = atoi(argv[4]);
    int fd;
    int i;

    // Use a named semaphore for the toggle bit
    sem_t *sem = sem_open( "toggle", O_CREAT, 0666, 1 );
    if( sem )
    {
        sem_getvalue( sem, &toggle );
        sem_post( sem );
    }
  
    int pulses[1000];
    int count = 0;

    switch( command )
    {
        case 0: count = send_brake( pulses, toggle, channel, output ); break;
        case 1: count = send_forward_pwm( pulses, toggle, channel, output, speed ); break;
        case 2: count = send_reverse_pwm( pulses, toggle, channel, output, speed ); break;
    }

    // lirc_rpi doesn't want to see trailing space (requires count to be odd)
    count--;

    // Open lirc_rpi devices directly
    fd = open( "/dev/lirc0", O_WRONLY );

    // Send command 5 times
    // Didn't bother to implment anti-collision
    for( i = 0; i < 5; i++ )
    {
        write( fd, (char *)pulses, count*sizeof(int) );
        usleep( 128000 );
    }
    close( fd );

    return 0;
}
