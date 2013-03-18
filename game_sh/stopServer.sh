#!/bin/bash
stopServer()
{
  kill -9 `ps aux |grep SCREEN|awk '{print $2}'`
  screen -wipe
  printf 'now screen:\n'
  screen -ls
}
stopServer

