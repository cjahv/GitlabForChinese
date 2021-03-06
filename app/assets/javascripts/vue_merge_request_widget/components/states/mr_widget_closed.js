import mrWidgetAuthorTime from '../../components/mr_widget_author_time';

export default {
  name: 'MRWidgetClosed',
  props: {
    mr: { type: Object, required: true },
  },
  components: {
    'mr-widget-author-and-time': mrWidgetAuthorTime,
  },
  template: `
    <div class="mr-widget-body">
      <mr-widget-author-and-time
        actionText="Closed by"
        :author="mr.closedBy"
        :dateTitle="mr.updatedAt"
        :dateReadable="mr.closedAt"
      />
      <section>
        <p>
          变更无法合并到
          <a
            :href="mr.targetBranchPath"
            class="label-branch">
            {{mr.targetBranch}}</a>.
        </p>
      </section>
    </div>
  `,
};
