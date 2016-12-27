/* eslint-disable space-before-function-paren, no-unused-expressions, no-var, object-shorthand, comma-dangle, semi, padded-blocks, max-len */
/* global Notes */

/*= require notes */
/*= require autosize */
/*= require gl_form */
/*= require lib/utils/text_utility */

(function() {
  window.gon || (window.gon = {});
  window.gl = window.gl || {};
  gl.utils = gl.utils || {};

  describe('Notes', function() {
    var commentsTemplate = 'issues/issue_with_comment.raw';
    fixture.preload(commentsTemplate);

    beforeEach(function () {
      fixture.load(commentsTemplate);
      gl.utils.disableButtonIfEmptyField = _.noop;
      window.project_uploads_path = 'http://test.host/uploads';
    });

    describe('task lists', function() {
      beforeEach(function() {
        $('form').on('submit', function(e) {
          e.preventDefault();
        });
        this.notes = new Notes();
      });

      it('modifies the Markdown field', function() {
        $('input[type=checkbox]').attr('checked', true).trigger('change');
        expect($('.js-task-list-field').val()).toBe('- [x] Task List Item');
      });

      it('submits the form on tasklist:changed', function() {
        var submitted = false;
        $('form').on('submit', function(e) {
          submitted = true;
          e.preventDefault();
        });

        $('.js-task-list-field').trigger('tasklist:changed');
        expect(submitted).toBe(true);
      });
    });

    describe('comments', function() {
      var textarea = '.js-note-text';

      beforeEach(function() {
        this.notes = new Notes();

        this.autoSizeSpy = spyOnEvent($(textarea), 'autosize:update');
        spyOn(this.notes, 'renderNote').and.stub();

        $(textarea).data('autosave', {
          reset: function() {}
        });

        $('form').on('submit', function(e) {
          e.preventDefault();
          $('.js-main-target-form').trigger('ajax:success');
        });
      });

      it('autosizes after comment submission', function() {
        $(textarea).text('这是一个示例注释');
        expect(this.autoSizeSpy).not.toHaveBeenTriggered();

        $('.js-comment-button').click();
        expect(this.autoSizeSpy).toHaveBeenTriggered();
      })
    });
  });

}).call(this);
