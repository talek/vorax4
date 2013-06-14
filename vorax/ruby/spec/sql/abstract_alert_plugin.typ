CREATE OR REPLACE TYPE "XXX"."ABSTRACT_ALERT_PLUGIN"
/**
  The basic implementation for an alert plugin. All alert plugins must extend this class.
*/
under abstract_plugin
(
  /**
    a number used by the core to sort all registred alert plugins when they are about to be invoked.
  */
  eval_order integer,

  /**
    this field specify the number of days after which the same alert message will be sent again. if
    there is needed to use a finer granularity like hours or minutes then the 1/24/60 formula may
    be used. This field is used by the core in flooding prevention mechanism.
  */
  flood_interval number,

  /**
    this method is invoked by the core in order to report/alert something.

    #param pi_short the short version of the alert/message
    #param pi_long the long version of the alert/message
    #param pi_severity the severity level of the alert.
  */
  not instantiable member procedure alert(pi_short in varchar2, pi_long in varchar2, pi_severity in varchar2),

  /**
    this method is used to build up and return the alert plugin instance with the provided ID.

    #param pi_plugin_id the plugin identifier

    #return an object instance to the requested plugin or null if the provided identifier is not
    found.
  */
  static function get(pi_plugin_id in varchar2) return abstract_alert_plugin

)
not final not instantiable
/
CREATE OR REPLACE TYPE BODY "XXX"."ABSTRACT_ALERT_PLUGIN" is

  static function get(pi_plugin_id in varchar2) return abstract_alert_plugin as
    l_plugin abstract_alert_plugin;
    l_cmd varchar2(4000);
  begin
    for x in (select * from alert_plugin where id = pi_plugin_id) loop
      l_cmd := 'begin :1 := ' || x.plsql_module || '(:2, :3, :4, :5); end;';
      ol.debug(l_cmd);
      execute immediate l_cmd
        using out l_plugin, in x.id, x.custom_params, x.eval_order, x.flood_interval;
      ol.debug(anydata.convertObject(l_plugin).getTypeName());
      return l_plugin;
    end loop;
    -- the requested plugin is not registered
    ol.error('the "{1}" plugin is not registered', pi_plugin_id);
    raise_application_error(core.plugin_not_registered_errno, core.plugin_not_registered_msg);
  end;

end;
/

