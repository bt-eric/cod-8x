<?php

function cod_install_tasks() {

  //make sure we have more memory than 196M. if not lets try to increase it.
  if (ini_get('memory_limit') != '-1' && ini_get('memory_limit') <= '196M') {
    ini_set('memory_limit', '196M');
  }

  // To Do - demo content
  //$demo_content = variable_get('cod_install_example_content', FALSE);
  
  // To Do - Acquia Connector
  //$acquia_connector = variable_get('cod_install_acquia_connector', FALSE);

  return array(
    //'cod_acquia_connector_enable' => array(
    //  'display' => FALSE,
    //  'type' => '',
    //  'run' => $acquia_connector ? INSTALL_TASK_RUN_IF_NOT_COMPLETED : INSTALL_TASK_SKIP,
    //),
    //'cod_demo_content' => array(
    //  'display' => FALSE,
    //  'type' => '',
    //  'run' => $demo_content ? INSTALL_TASK_RUN_IF_NOT_COMPLETED : INSTALL_TASK_SKIP,
    //),
    'cod_create_first_event' => array(
      'display_name' => st('Create your first event'),
      'display' => TRUE,
      'type' => 'form',
    ),
  );
}

/**
 * Helper function defines the COD modules. -- will use this later so people can select COD features on install. Not useful right now
 */
function _cod_profile_modules() {
  return array(
    'cod_base',
    'cod_session',
    'cod_events',
    'cod_community',
    'cod_front_page',
    'cod_news',
    'cod_sponsors',
  );
}

/**
 * Implements hook_form_alter().
 * Set COD as the default profile.
 * (copied from Atrium: We use system_form_form_id_alter, otherwise we cannot alter forms.)
 */
function system_form_install_select_profile_form_alter(&$form, $form_state) {
  foreach ($form['profile'] as $key => $element) {
    $form['profile'][$key]['#value'] = 'cod';
  }
}

/**
 * Let the admin user create the first group as part of the installation process
 */
function cod_create_first_event() {
  $form['cod_first_event_explanation'] = array(
    '#markup' => '<h2>' . st('Create your first event.') . '</h2>' . st("COD allows you to create multiple events and organizes content related to a particular event, such as sessions, attendees, and announcements."),
    '#weight' => -1,
  );

  $form['cod_first_event_title'] = array(
    '#type' => 'textfield',
    '#title' => st("Event name"),
    '#description' => st('This is the name of your conference or event. You may want to include the year or date if this is a repeating event.'),
    '#required' => TRUE,
    '#default_value' => st('DrupalCamp Antarctica'),
  );

  $form['cod_first_event_body'] = array(
    '#type' => 'textarea',
    '#title' => st('Event description'),
    '#description' => st("This text will appear on the event's homepage and gives a general overview of your event. You can always change this text later."),
    '#required' => TRUE,
    '#default_value' => st('DrupalCamp Antarctica is held once a year at the South Pole, with a regular attendance of around 200 penguins'),
  );

  $form['cod_first_event_modules'] = array(
    '#type' => 'checkboxes',
    '#title' => st('Optional Event Features'),
    '#description' => st("Select the optional features above that are relevant to your event."),
    '#required' => FALSE,
    '#options' => _get_cod_optional_modules(),
  );

  $form['cod_first_event_submit'] = array(
    '#type'  => 'submit',
    '#value' => st('Save and continue')
  );

  return $form;
}

/**
 * Save the first group form
 *
 * @see commons_create_first_group().
 */
function cod_create_first_event_submit($form_id, &$form_state) {
  $values = $form_state['values'];

  if (isset($values['cod_first_event_modules'])) {
    module_enable(array_keys($values['cod_first_event_modules']));
  }

  $first_group = new stdClass();
  $first_group->type = 'event';
  node_object_prepare($first_group);

  $first_group->title = $values['cod_first_event_title'];
  $first_group->body[LANGUAGE_NONE][0]['value'] = $values['cod_first_event_body'];
  $first_group->uid = 1;
  $first_group->language = LANGUAGE_NONE;
  $first_group->status = 1;
  node_save($first_group);
}

function _get_cod_optional_modules() {
  $modules = system_rebuild_module_data();
  $cod_modules = array();
  foreach($modules AS $module_name => $module) {
    if(strpos($module_name, 'cod_') === 0 && isset($module->info['install_option']) && $module->info['install_option'] == 'cod') {
      $cod_modules[$module_name] = $module->info['description'] ? $module->info['description'] : $module_name;
    }
  }
  return $cod_modules;
}