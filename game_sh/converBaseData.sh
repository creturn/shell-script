#!/bin/bash
source ./config.sh
ROOT_DD=$ErlangRoot  #'/home/return/workspace/erlang/webgame/zttx/'
cd ${ROOT_DD}

cd ebin
erl -s mysql_to_emongo start_base
echo 'Conver Finshed!'
