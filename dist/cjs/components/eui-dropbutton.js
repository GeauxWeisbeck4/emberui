"use strict";
var styleSupport = require("../mixins/style-support")["default"] || require("../mixins/style-support");
var sizeSupport = require("../mixins/size-support")["default"] || require("../mixins/size-support");
var poplistComponent = require("../components/eui-poplist")["default"] || require("../components/eui-poplist");
var dropbutton;

dropbutton = Em.Component.extend(styleSupport, sizeSupport, {
  tagName: 'eui-dropbutton',
  classNameBindings: ['primaryAction:eui-groupbutton:eui-singlebutton'],
  poplistIsOpen: false,
  listWidth: 'auto',
  primaryAction: Em.computed(function() {
    return this.get('options').findBy('primary', true);
  }).property('options'),
  peformSecondaryAction: (function() {
    var action;
    action = this.get('selection.action');
    if (action) {
      this.triggerAction({
        action: action
      });
    }
    return this.set('selection', null);
  }).observes('selection'),
  optionsWithoutPrimaryAction: Ember.computed.filter('options', function(option) {
    return !option.primary;
  }).property("options"),
  actions: {
    toggleWindow: function() {
      if (!this.get('poplistIsOpen')) {
        return poplistComponent.show({
          targetObject: this,
          isOpenBinding: 'targetObject.poplistIsOpen',
          selectionBinding: 'targetObject.selection',
          optionsBinding: 'targetObject.optionsWithoutPrimaryAction',
          labelPath: 'label',
          style: 'bubble',
          listWidth: this.get('listWidth')
        });
      }
    },
    primaryAction: function() {
      return this.sendAction('primaryAction.action', this);
    }
  }
});

exports["default"] = dropbutton;