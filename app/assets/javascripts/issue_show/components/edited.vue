<script>
import timeAgoTooltip from '../../vue_shared/components/time_ago_tooltip.vue';

export default {
  props: {
    updatedAt: {
      type: String,
      required: false,
      default: '',
    },
    updatedByName: {
      type: String,
      required: false,
      default: '',
    },
    updatedByPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  components: {
    timeAgoTooltip,
  },
  computed: {
    hasUpdatedBy() {
      return this.updatedByName && this.updatedByPath;
    },
  },
};
</script>

<template>
  <small
    class="edited-text"
  >
    编辑于
    <time-ago-tooltip
      v-if="updatedAt"
      placement="bottom"
      :time="updatedAt"
    />
    <span
      v-if="hasUpdatedBy"
    >
      作者
      <a
        class="author_link"
        :href="updatedByPath"
      >
        <span>{{updatedByName}}</span>
      </a>
    </span>
  </small>
</template>
