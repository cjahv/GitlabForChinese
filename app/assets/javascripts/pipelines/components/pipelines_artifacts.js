export default {
  props: {
    artifacts: {
      type: Array,
      required: true,
    },
  },

  template: `
    <div class="btn-group" role="group">
      <button
        class="dropdown-toggle btn btn-default build-artifacts has-tooltip js-pipeline-dropdown-download"
        title="工件"
        data-placement="top"
        data-toggle="dropdown"
        aria-label="工件">
        <i class="fa fa-download" aria-hidden="true"></i>
        <i class="fa fa-caret-down" aria-hidden="true"></i>
      </button>
      <ul class="dropdown-menu dropdown-menu-align-right">
        <li v-for="artifact in artifacts">
          <a
            rel="nofollow"
            download
            :href="artifact.path">
            <i class="fa fa-download" aria-hidden="true"></i>
            <span>下载{{artifact.name}}工件</span>
          </a>
        </li>
      </ul>
    </div>
  `,
};
