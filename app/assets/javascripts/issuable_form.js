/* eslint-disable func-names, space-before-function-paren, no-var, prefer-rest-params, wrap-iife, no-use-before-define, no-useless-escape, no-new, quotes, object-shorthand, no-unused-vars, comma-dangle, no-alert, consistent-return, no-else-return, prefer-template, one-var, one-var-declaration-per-line, curly, max-len */
/* global GitLab */
/* global UsersSelect */
/* global ZenMode */
/* global Autosave */
/* global dateFormat */
/* global Pikaday */

(function() {
  var bind = function(fn, me) { return function() { return fn.apply(me, arguments); }; };

  this.IssuableForm = (function() {
    IssuableForm.prototype.issueMoveConfirmMsg = 'Are you sure you want to move this issue to another project?';

    IssuableForm.prototype.wipRegex = /^\s*(\[WIP\]\s*|WIP:\s*|WIP\s+)+\s*/i;

    function IssuableForm(form) {
      var $issuableDueDate, calendar;
      this.form = form;
      this.toggleWip = bind(this.toggleWip, this);
      this.renderWipExplanation = bind(this.renderWipExplanation, this);
      this.resetAutosave = bind(this.resetAutosave, this);
      this.handleSubmit = bind(this.handleSubmit, this);
      gl.GfmAutoComplete.setup();
      new UsersSelect();
      new ZenMode();
      this.titleField = this.form.find("input[name*='[title]']");
      this.descriptionField = this.form.find("textarea[name*='[description]']");
      this.issueMoveField = this.form.find("#move_to_project_id");
      if (!(this.titleField.length && this.descriptionField.length)) {
        return;
      }
      this.initAutosave();
      this.form.on("submit", this.handleSubmit);
      this.form.on("click", ".btn-cancel", this.resetAutosave);
      this.initWip();
      this.initMoveDropdown();
      $issuableDueDate = $('#issuable-due-date');
      if ($issuableDueDate.length) {
        calendar = new Pikaday({
          field: $issuableDueDate.get(0),
          theme: 'gitlab-theme animate-picker',
          format: 'yyyy-mm-dd',
          container: $issuableDueDate.parent().get(0),
          i18n: {previousMonth:'上个月',nextMonth:'下个月',months:['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'],weekdays:['周日','周一','周二','周三','周四','周五','周六'],weekdaysShort:['日','一','二','三','四','五','六']},
          onSelect: function(dateText) {
            $issuableDueDate.val(dateFormat(new Date(dateText), 'yyyy-mm-dd'));
          }
        });
        calendar.setDate(new Date($issuableDueDate.val()));
      }
    }

    IssuableForm.prototype.initAutosave = function() {
      new Autosave(this.titleField, [document.location.pathname, document.location.search, "title"]);
      return new Autosave(this.descriptionField, [document.location.pathname, document.location.search, "description"]);
    };

    IssuableForm.prototype.handleSubmit = function() {
      var fieldId = (this.issueMoveField != null) ? this.issueMoveField.val() : null;
      if ((parseInt(fieldId, 10) || 0) > 0) {
        if (!confirm(this.issueMoveConfirmMsg)) {
          return false;
        }
      }
      return this.resetAutosave();
    };

    IssuableForm.prototype.resetAutosave = function() {
      this.titleField.data("autosave").reset();
      return this.descriptionField.data("autosave").reset();
    };

    IssuableForm.prototype.initWip = function() {
      this.$wipExplanation = this.form.find(".js-wip-explanation");
      this.$noWipExplanation = this.form.find(".js-no-wip-explanation");
      if (!(this.$wipExplanation.length && this.$noWipExplanation.length)) {
        return;
      }
      this.form.on("click", ".js-toggle-wip", this.toggleWip);
      this.titleField.on("keyup blur", this.renderWipExplanation);
      return this.renderWipExplanation();
    };

    IssuableForm.prototype.workInProgress = function() {
      return this.wipRegex.test(this.titleField.val());
    };

    IssuableForm.prototype.renderWipExplanation = function() {
      if (this.workInProgress()) {
        this.$wipExplanation.show();
        return this.$noWipExplanation.hide();
      } else {
        this.$wipExplanation.hide();
        return this.$noWipExplanation.show();
      }
    };

    IssuableForm.prototype.toggleWip = function(event) {
      event.preventDefault();
      if (this.workInProgress()) {
        this.removeWip();
      } else {
        this.addWip();
      }
      return this.renderWipExplanation();
    };

    IssuableForm.prototype.removeWip = function() {
      return this.titleField.val(this.titleField.val().replace(this.wipRegex, ""));
    };

    IssuableForm.prototype.addWip = function() {
      return this.titleField.val("WIP: " + (this.titleField.val()));
    };

    IssuableForm.prototype.initMoveDropdown = function() {
      var $moveDropdown, pageSize;
      $moveDropdown = $('.js-move-dropdown');
      if ($moveDropdown.length) {
        pageSize = $moveDropdown.data('page-size');
        return $('.js-move-dropdown').select2({
          ajax: {
            url: $moveDropdown.data('projects-url'),
            quietMillis: 125,
            data: function(term, page, context) {
              return {
                search: term,
                offset_id: context
              };
            },
            results: function(data) {
              var context,
                more;

              if (data.length >= pageSize)
                more = true;

              if (data[data.length - 1])
                context = data[data.length - 1].id;

              return {
                results: data,
                more: more,
                context: context
              };
            }
          },
          formatResult: function(project) {
            return project.name_with_namespace;
          },
          formatSelection: function(project) {
            return project.name_with_namespace;
          }
        });
      }
    };

    return IssuableForm;
  })();
}).call(window);
