#!/bin/bash

../../../../script/noosfero-plugins disable distribution
../../../../script/noosfero-plugins enable distribution
../../../../script/noosfero-plugins disable orders
../../../../script/noosfero-plugins enable orders
../../../../script/noosfero-plugins disable delivery
../../../../script/noosfero-plugins enable delivery

ln -sf `ls orders_plugin_move/*` `ls suppliers_plugin_move/*` `ls delivery_plugin_move/*` .

rake db:migrate --trace
rake db:migrate --trace

find -type l -delete
