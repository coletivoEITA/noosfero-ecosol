#!/bin/bash

SOURCE=$0; while [ -L "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done; cd -P "$(dirname "$SOURCE")"
set -x
set -e

noosfero_plugins=../../../../script/noosfero-plugins

PLUGINS="suppliers delivery orders orders_cycle consumers_coop"
for plugin in $PLUGINS; do
  $noosfero_plugins disable $plugin
  $noosfero_plugins enable $plugin
done

runner=../../../../script/runner
$runner 'e=Environment.default; e.enabled_plugins = ["ShoppingCartPlugin", "SolrPlugin", "DeliveryPlugin", "OrdersPlugin", "OrdersCyclePlugin", "SuppliersPlugin", "ConsumersCoopPlugin"]; e.save'

MIGRATIONS=""
for plugin in $PLUGINS; do
  MIGRATIONS+="${plugin}_plugin_move/* "
done
ln -sf $MIGRATIONS .

$noosfero_plugins enable distribution
rake db:migrate --trace
$noosfero_plugins disable distribution

find -type l -delete
