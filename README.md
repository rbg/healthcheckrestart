# Healthcheckrestart

## Usage

`git clone https://github.com/xmattstrongx/healthcheckrestart.git`

> The script acts as a CLI which takes in a `-u` or `--url` flag which is the healthcheck url being exposed by the foobar service.

Example: 

```./monitor.sh -u http://localhost:8080/healthcheck```

## Assumptions
*  For this project I am assuming that the foobar service is an executable binary located in the same folder as the `monitor.sh` file. Had this been a live fire exercise most like foobar would be setup as a process in the init.d folder. This way the status checks and restarts would have been more like: 
`sudo service start|status|restart`

* Also I am logging out straight to the command line. In a real app this would not be as useful as logging to STDERR which would be shipped off to an ELK stack or something.

## How it works

The monitor script will take action if:
1. If the foobar service is not running it will start it.
2. If the healthcheck endpoint responds with a 500 it will restart foobar.

## Time
* I spent approxiamately 1 hour on this problem.

## foorbar.go

I wrote a tiny go app to simulate the randomness of either a 200 or a 500 responce. If you would like to use it to test with simply run `go build -o foobar`

Note: The monitor script does not gracefully shut down as is so it may leave foobar processes stranded. `killall foobar` command will take care of that.