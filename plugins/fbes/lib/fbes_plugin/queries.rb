class FbesPlugin::Queries

  Hash = {
    :orders_by_month =>
      "select to_char(created_at,'YYYY-MM') mes, count(*)
        from orders_plugin_orders
        group by mes
        order by mes desc",
    :enterprises_updated_products =>
      "create temporary table tmp as
        select profile_id, to_char(updated_at,'YYYY-MM') mes, count(*) qtde
          from products
          group by mes, profile_id
          order by mes desc, profile_id;

        select a.mes, a.profile_id, b.name, 'http://cirandas.net/'||b.identifier url, a.qtde
          from tmp a, profiles b
          where a.profile_id=b.id and b.type='Enterprise' and visible=true and active=true
          order by a.mes desc, a.qtde desc",
    :enterprises_products_ranking =>
      "create temporary table tmp as
          select profile_id, count(*) qtde from products group by profile_id order by qtde desc;

      select a.profile_id, b.name, 'http://cirandas.net/'||b.identifier url, a.qtde from tmp a, profiles b
          where a.profile_id=b.id and b.type='Enterprise' and visible=true and active=true
          order by qtde desc",
    :enterprises_orders_ranking =>
      "create temporary table tmp as
          select a.id order_id, a.profile_id, b.name, 'http://cirandas.net/'||b.identifier url, (select sum(i.price) from orders_plugin_items i where i.order_id=a.id) valor_dos_pedidos
              from orders_plugin_orders a, profiles b
              where a.profile_id=b.id and b.type='Enterprise' and b.visible=true and b.active=true;

      select t.profile_id, b.name, b.url, t.qtde, t.total_pedidos
          from (select profile_id, count(*) qtde, sum(valor_dos_pedidos) total_pedidos, max(order_id) m
                  from tmp
                  group by profile_id
              ) t
          join tmp b on b.profile_id=t.profile_id and b.order_id=t.m
          order by t.qtde desc",
    :enterprises_orders_quantity_by_month =>
      "create temporary table tmp as
          select a.id order_id, a.profile_id, a.created_at, b.name, 'http://cirandas.net/'||b.identifier url, (select sum(i.price) from orders_plugin_items i where i.order_id=a.id) valor_dos_pedidos
              from orders_plugin_orders a, profiles b
              where a.profile_id=b.id and b.type='Enterprise' and b.visible=true and b.active=true;

      select t.mes, t.profile_id, b.name, b.url, t.qtde, t.total_pedidos
          from (select to_char(created_at,'YYYY-MM') mes, profile_id, count(*) qtde, sum(valor_dos_pedidos) total_pedidos, max(order_id) m
                  from tmp
                  group by mes, profile_id
              ) t
          join tmp b on b.profile_id=t.profile_id and b.order_id=t.m
          order by t.mes desc, t.qtde desc",
    :enterprises_quantity_with_orders_by_month =>
      "create temporary table tmp as
          select a.id order_id, a.profile_id, a.created_at, b.name, 'http://cirandas.net/'||b.identifier url, (select sum(i.price) from orders_plugin_items i where i.order_id=a.id) valor_dos_pedidos
              from orders_plugin_orders a, profiles b
              where a.profile_id=b.id and b.type='Enterprise' and b.visible=true and b.active=true;

      select t.mes, count(*) qtde_ees, sum(t.qtde) qtde_pedidos, sum(t.total_pedidos) valor_total_pedidos
          from (select to_char(created_at,'YYYY-MM') mes, profile_id, count(*) qtde, sum(valor_dos_pedidos) total_pedidos, max(order_id) m
                            from tmp
                            group by mes, profile_id
                        ) t
          join tmp b on b.profile_id=t.profile_id and b.order_id=t.m
          group by t.mes
          order by t.mes desc",
    :users_created_by_month =>
      "select to_char(created_at, 'YYYY-MM') mes, count(*) qtde
        from profiles
        where type='Person' group by mes
        order by mes desc",
    :communities_created_by_month =>
      "select to_char(created_at, 'YYYY-MM') mes, count(*) qtde
        from profiles
        where type='Community'
        group by mes
        order by mes desc",
    :comments_created_by_month =>
      "select to_char(created_at, 'YYYY-MM') mes, count(*) qtde
        from comments
        where spam is not true and source_type='Article'
        group by mes
        order by mes desc",
    :contents_most_commented =>
      "select t.source_id, a.name, a.type, a.created_at, t.qtde_comentarios
        from (select source_id, count(*) qtde_comentarios
                     from comments
                     where spam is not true and source_type='Article'
                     group by source_id
                 ) t join articles a on a.id=t.source_id
        order by qtde_comentarios desc",
  }
end
