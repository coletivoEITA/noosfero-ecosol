#!/bin/bash

set -x

noosfero_plugins=../../../../script/noosfero-plugins
$noosfero_plugins disable distribution
$noosfero_plugins enable distribution

runner=../../../../script/runner
$runner 'e=Environment.default; e.enabled_plugins = ["ShoppingCartPlugin", "SolrPlugin", "DeliveryPlugin", "OrdersPlugin", "OrdersCyclePlugin", "SuppliersPlugin", "ConsumersCoopPlugin"]; e.save'

PLUGINS="suppliers delivery orders orders_cycle consumers_coop"
for plugin in $PLUGINS; do
  $noosfero_plugins disable $plugin
  $noosfero_plugins enable $plugin
done

MIGRATIONS=""
for plugin in $PLUGINS; do
  MIGRATIONS+="${plugin}_plugin_move/* "
done

ln -sf $MIGRATIONS .

rake db:migrate --trace
rake db:migrate --trace

find -type l -delete
