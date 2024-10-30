import "dotenv/config";
import { Client } from "pg";
import { backOff } from "exponential-backoff";
import express, { Request, Response } from "express";
import waitOn from "wait-on";
import onExit from "signal-exit";
import cors from "cors";

// Add your routes here
const setupApp = (client: Client): express.Application => {
  const app: express.Application = express();

  app.use(cors());

  app.use(express.json());

  app.get("/examples", async (_req, res) => {
    try {
      const { rows } = await client.query(`SELECT * FROM example_table`);
      res.status(200).json(rows);  // Use return to stop further execution
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Database query failed" });
    }
  });

  app.get("/styles/:componentId", async (req: Request, res: Response) => {
    const { componentId } = req.params;
    try {
      const { rows } = await client.query(
        `SELECT * FROM component_styles WHERE component_id = $1`,
        [componentId]
      );
      if (rows.length > 0) {
        const { margin_top, margin_bottom, margin_left, margin_right, padding_top, padding_bottom, padding_left, padding_right } = rows[0];
        return res.status(200).json({
          margin: {
            top: margin_top,
            bottom: margin_bottom,
            left: margin_left,
            right: margin_right,
          },
          padding: {
            top: padding_top,
            bottom: padding_bottom,
            left: padding_left,
            right: padding_right,
          },
        });
      } else {
        return res.status(200).json({});
      }
    } catch (error) {
      return res.status(500).json({ error });
    }
  });

  app.put("/styles/:componentId", async (req: Request, res: Response) => {
    const { componentId } = req.params;
    const { margin, padding } = req.body;

    if (!margin || !padding) {
      console.log("No margin or padding provided");
      return res.status(400).json({ message: "No margin or padding provided" });
    }

    const { top: margin_top, bottom: margin_bottom, left: margin_left, right: margin_right } = margin;
    const { top: padding_top, bottom: padding_bottom, left: padding_left, right: padding_right } = padding;

    try {
      await client.query(
        `INSERT INTO component_styles (
        component_id, margin_top, margin_bottom, margin_left, margin_right, 
        padding_top, padding_bottom, padding_left, padding_right
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      ON CONFLICT (component_id) DO UPDATE 
      SET margin_top = $2, margin_bottom = $3, margin_left = $4, margin_right = $5, 
          padding_top = $6, padding_bottom = $7, padding_left = $8, padding_right = $9`,
        [componentId, margin_top, margin_bottom, margin_left, margin_right, padding_top, padding_bottom, padding_left, padding_right]
      );
      return res.status(200).json({ message: "Successfully updated styles" });
    } catch (error) {
      return res.status(500).json(error);
    }
  });


  return app;
};

// Waits for the database to start and connects
const connect = async (): Promise<Client> => {
  console.log("Connecting");
  const resource = `tcp:${process.env.PGHOST}:${process.env.PGPORT}`;
  console.log(`Waiting for ${resource}`);
  await waitOn({ resources: [resource] });
  console.log("Initializing client");
  const client = new Client();
  await client.connect();
  console.log("Connected to database");

  // Ensure the client disconnects on exit
  onExit(async () => {
    console.log("onExit: closing client");
    await client.end();
  });

  return client;
};

const main = async () => {
  const client = await connect();
  const app = setupApp(client);
  const port = parseInt(process.env.SERVER_PORT);
  app.listen(port, () => {
    console.log(
      `Draftbit Coding Challenge is running at http://localhost:${port}/`
    );
  });
};

main();
