// graphify OpenCode plugin
// Injects a knowledge graph reminder before shell tool calls when the graph exists.
// Supports OpenCode V2 (default export with id + setup) and V1 (server()).
import { existsSync } from "fs";
import { join } from "path";

// Single-quoted in the shell so the backticks/quotes are not expanded.
const REMINDER =
  "echo '[graphify] knowledge graph at graphify-out/. For focused questions, run: graphify query \"<question>\" (scoped subgraph, usually much smaller than GRAPH_REPORT.md) instead of grepping raw files. Read GRAPH_REPORT.md only for broad architecture context.' && ";

const hasGraph = (directory) =>
  existsSync(join(directory, "graphify-out", "graph.json"));

export default {
  id: "graphify",

  // OpenCode V2
  async setup(ctx) {
    const directory = ctx.location.directory;
    let reminded = false;

    await ctx.tool.hook("execute.before", (event) => {
      if (reminded) return;
      if (event.tool !== "shell" && event.tool !== "bash") return;
      if (!hasGraph(directory)) return;

      const input = event.input;
      if (!input || typeof input.command !== "string") return;

      event.input = { ...input, command: REMINDER + input.command };
      reminded = true;
    });
  },

  // OpenCode V1
  async server({ directory }) {
    let reminded = false;

    return {
      "tool.execute.before": async (input, output) => {
        if (reminded) return;
        if (input.tool !== "bash") return;
        if (!hasGraph(directory)) return;

        output.args.command = REMINDER + output.args.command;
        reminded = true;
      },
    };
  },
};
