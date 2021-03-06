import PipelineStage from '../../pipelines/components/stage.vue';
import ciIcon from '../../vue_shared/components/ci_icon.vue';
import { statusIconEntityMap } from '../../vue_shared/ci_status_icons';

export default {
  name: 'MRWidgetPipeline',
  props: {
    mr: { type: Object, required: true },
  },
  components: {
    'pipeline-stage': PipelineStage,
    ciIcon,
  },
  computed: {
    hasCIError() {
      const { hasCI, ciStatus } = this.mr;

      return hasCI && !ciStatus;
    },
    svg() {
      return statusIconEntityMap.icon_status_failed;
    },
    stageText() {
      return this.mr.pipeline.details.stages.length > 1 ? 'stages' : 'stage';
    },
    status() {
      return this.mr.pipeline.details.status || {};
    },
  },
  template: `
    <div class="mr-widget-heading">
      <div class="ci-widget">
        <template v-if="hasCIError">
          <div class="ci-status-icon ci-status-icon-failed ci-error js-ci-error">
            <span class="js-icon-link icon-link">
              <span
                v-html="svg"
                aria-hidden="true"></span>
            </span>
          </div>
          <span>无法连接到 CI 服务器。请检查相关设置并重试。</span>
        </template>
        <template v-else>
          <div>
            <a
              class="icon-link"
              :href="this.status.details_path">
              <ci-icon :status="status" />
            </a>
          </div>
          <span>
            流水线
            <a
              :href="mr.pipeline.path"
              class="pipeline-id">#{{mr.pipeline.id}}</a>
            {{mr.pipeline.details.status.label}}
            with {{stageText}}
          </span>
          <div class="mr-widget-pipeline-graph">
            <div class="stage-cell">
              <div
                v-if="mr.pipeline.details.stages.length > 0"
                v-for="stage in mr.pipeline.details.stages"
                class="stage-container dropdown js-mini-pipeline-graph">
                <pipeline-stage :stage="stage" />
              </div>
            </div>
          </div>
          <span>
            for
            <a
              :href="mr.pipeline.commit.commit_path"
              class="monospace js-commit-link">
              {{mr.pipeline.commit.short_id}}</a>.
          </span>
          <span
            v-if="mr.pipeline.coverage"
            class="js-mr-coverage">
            覆盖率 {{mr.pipeline.coverage}}%.
          </span>
        </template>
      </div>
    </div>
  `,
};
