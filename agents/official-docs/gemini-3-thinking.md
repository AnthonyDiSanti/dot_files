> [!NOTE]
> To see an example of Gemini 2.5 Flash,
> run the "Intro to Gemini 2.5 Flash" notebook in one of the following
> environments:
>
> [![](https://docs.cloud.google.com/static/vertex-ai/images/colab-logo-32px.png)Open in Colab](https://colab.research.google.com/github/GoogleCloudPlatform/generative-ai/blob/main/gemini/getting-started/intro_gemini_2_5_flash.ipynb)
>
>
> \|
>
> [![](https://docs.cloud.google.com/static/vertex-ai/images/colab-enterprise-logo-32px.png)Open in Colab Enterprise](https://console.cloud.google.com/vertex-ai/colab/import/https%3A%2F%2Fraw.githubusercontent.com%2FGoogleCloudPlatform%2Fgenerative-ai%2Fmain%2Fgemini%2Fgetting-started%2Fintro_gemini_2_5_flash.ipynb)
>
>
> \|
>
> [![](https://docs.cloud.google.com/static/vertex-ai/images/vertex-ai-workbench-logo-32px.png)Open
> in Vertex AI Workbench](https://console.cloud.google.com/vertex-ai/workbench/deploy-notebook?download_url=https://raw.githubusercontent.com/GoogleCloudPlatform/generative-ai/main/gemini/getting-started/intro_gemini_2_5_flash.ipynb)
>
>
> \|
>
> [![](https://docs.cloud.google.com/static/vertex-ai/images/github-logo-32px.png)View on GitHub](https://github.com/GoogleCloudPlatform/generative-ai/blob/main/gemini/getting-started/intro_gemini_2_5_flash.ipynb)

Thinking models are trained to generate the "thinking process" the model goes
through as part of its response. As a result, thinking models are capable of
stronger reasoning capabilities in its responses than equivalent base models.

The thinking process is enabled by default. When you use
Vertex AI Studio, you can view the full thinking process together
with the model's generated response.

## Supported models

Thinking is supported in the following models:

- [Gemini 3.1 Flash-Lite](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-1-flash-lite) preview
- [Gemini 3.1 Flash Image](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-1-flash-image) preview
- [Gemini 3.1 Pro](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-1-pro) preview
- [Gemini 3 Flash](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-flash) preview
- [Gemini 3 Pro Image](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-pro-image) preview
- [Gemini 2.5 Pro](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-pro)
- [Gemini 2.5 Flash](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-flash) preview
- [Gemini 2.5 Flash-Lite](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-flash-lite) preview
- [Gemini 2.5 Flash](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-flash)
- [Gemini 2.5 Flash-Lite](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-flash-lite)

## Use a thinking model

> [!NOTE]
> **Note:** [Fine-tuning](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini-supervised-tuning) isn't supported when thinking is enabled.

To use thinking with a supported model, do the following:

### Console

1. Open [**Vertex AI Studio \> Create prompt**](https://console.cloud.google.com/vertex-ai/studio/multimodal).
2. In the **Model** panel, click **Switch model** and select one of the [supported models](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thinking#supported-models) from the menu.
   - (Gemini 2.5 Flash only) **Thinking budget** is set to **Auto** by default when the model is loaded.
3. **(Optional)** Give the model some detailed instructions on how the model should format its responses in the **System instructions** field.
4. Enter a prompt in the **Write your prompt** field.
5. Click **Run**.


Gemini returns a response after the response is generated.
Depending on the complexity of the response, generation can take several
seconds:


(Gemini 2.5 Flash only) To turn thinking
off, set **Thinking budget** to **Off**.

### Python

#### Install

```
pip install --upgrade google-genai
```


To learn more, see the
[SDK reference documentation](https://googleapis.github.io/python-genai/).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    from google import genai

    client = genai.Client()
    response = client.models.generate_content(
        model="gemini-2.5-pro",
        contents="solve x^2 + 4x + 4 = 0",
    )
    print(response.text)
    # Example Response:
    #     Okay, let's solve the quadratic equation x² + 4x + 4 = 0.
    #
    #     We can solve this equation by factoring, using the quadratic formula, or by recognizing it as a perfect square trinomial.
    #
    #     **Method 1: Factoring**
    #
    #     1.  We need two numbers that multiply to the constant term (4) and add up to the coefficient of the x term (4).
    #     2.  The numbers 2 and 2 satisfy these conditions: 2 * 2 = 4 and 2 + 2 = 4.
    #     3.  So, we can factor the quadratic as:
    #         (x + 2)(x + 2) = 0
    #         or
    #         (x + 2)² = 0
    #     4.  For the product to be zero, the factor must be zero:
    #         x + 2 = 0
    #     5.  Solve for x:
    #         x = -2
    #
    #     **Method 2: Quadratic Formula**
    #
    #     The quadratic formula for an equation ax² + bx + c = 0 is:
    #     x = [-b ± sqrt(b² - 4ac)] / (2a)
    #
    #     1.  In our equation x² + 4x + 4 = 0, we have a=1, b=4, and c=4.
    #     2.  Substitute these values into the formula:
    #         x = [-4 ± sqrt(4² - 4 * 1 * 4)] / (2 * 1)
    #         x = [-4 ± sqrt(16 - 16)] / 2
    #         x = [-4 ± sqrt(0)] / 2
    #         x = [-4 ± 0] / 2
    #         x = -4 / 2
    #         x = -2
    #
    #     **Method 3: Perfect Square Trinomial**
    #
    #     1.  Notice that the expression x² + 4x + 4 fits the pattern of a perfect square trinomial: a² + 2ab + b², where a=x and b=2.
    #     2.  We can rewrite the equation as:
    #         (x + 2)² = 0
    #     3.  Take the square root of both sides:
    #         x + 2 = 0
    #     4.  Solve for x:
    #         x = -2
    #
    #     All methods lead to the same solution.
    #
    #     **Answer:**
    #     The solution to the equation x² + 4x + 4 = 0 is x = -2. This is a repeated root (or a root with multiplicity 2).

### Go

Learn how to install or update the [Go](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/sdks/overview).


To learn more, see the
[SDK reference documentation](https://pkg.go.dev/google.golang.org/genai).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    import (
    	"context"
    	"fmt"
    	"io"

    	"google.golang.org/genai"
    )

    // generateThinkingWithText shows how to generate thinking using a text prompt.
    func generateThinkingWithText(w io.Writer) error {
    	ctx := context.Background()

    	client, err := genai.NewClient(ctx, &genai.ClientConfig{
    		HTTPOptions: genai.HTTPOptions{APIVersion: "v1"},
    	})
    	if err != nil {
    		return fmt.Errorf("failed to create genai client: %w", err)
    	}

    	resp, err := client.Models.GenerateContent(ctx,
    		"gemini-2.5-flash",
    		genai.Text("solve x^2 + 4x + 4 = 0"),
    		nil,
    	)
    	if err != nil {
    		return fmt.Errorf("failed to generate content: %w", err)
    	}

    	respText := resp.Text()

    	fmt.Fprintln(w, respText)
    	// Example response:
    	// To solve the quadratic equation $x^2 + 4x + 4 = 0$, we can use a few methods:
    	//
    	// **Method 1: Factoring (Recognizing a Perfect Square Trinomial)**
    	// **1. The Foundation: Data and Algorithms**
    	//
    	// Notice that the left side of the equation is a perfect square trinomial.
    	// ...

    	return nil
    }

<br />

## Control model thinking

You can control the amount of thinking the model performs before returning a
response. The method for controlling thinking differs depending on the model
version.

### Gemini 3 and later models

Gemini 3 models introduce the `thinking_level` parameter, which
simplifies thinking budget configuration into levels. By default,
Gemini 3 models use dynamic thinking (`thinking_level.HIGH`) to
reason through prompts. For faster, lower-latency responses when complex
reasoning isn't required, you can constrain the model's `thinking_level`.

The following table summarizes which `thinking_level` values are supported by
each model:

| Model | Supported `thinking_level` values |
|---|---|
| `Gemini 3.1 Pro` | `LOW`, `MEDIUM`, `HIGH` |
| `Gemini 3.1 Flash-Lite` | `MINIMAL`, `LOW`, `MEDIUM`, `HIGH` |
| `Gemini 3.1 Flash Image` | `MINIMAL`, `HIGH` |
| `Gemini 3 Flash` | `MINIMAL`, `LOW`, `MEDIUM`, `HIGH` |
| `Gemini 3 Pro` | `LOW`, `MEDIUM`, `HIGH` |
| `Gemini 3 Pro Image` | `HIGH` |

- `MINIMAL`: **(Gemini 3 Flash, Gemini 3.1 Flash Image, and
  Gemini 3.1 Flash-Lite only)** Constrains the model to use as
  few tokens as possible for thinking and is best used for low-complexity
  tasks that wouldn't benefit from extensive reasoning. This is the default
  level for Gemini 3.1 Flash-Lite. `MINIMAL` is as close
  as possible to a zero budget for thinking but still requires [thought
  signatures](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thought-signatures). If thought signatures aren't provided in your request, the model
  returns a `400` error. For more information, see
  [Thought signatures](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thought-signatures).

      from google import genai
      from google.genai import types

      client = genai.Client()

      response = client.models.generate_content(
          model="gemini-3-flash-preview",
          contents="How does AI work?",
          config=types.GenerateContentConfig(
              thinking_config=types.ThinkingConfig(
                  thinking_level=types.ThinkingLevel.MINIMAL
              )
          ),
      )
      print(response.text)

- `LOW`: Constrains the model to use fewer tokens for thinking and is suitable for
  simpler tasks where extensive reasoning is not required. `LOW` is ideal for
  high-throughput tasks where speed is essential:

      from google import genai
      from google.genai import types

      client = genai.Client()

      response = client.models.generate_content(
          model="gemini-3.1-pro-preview",
          contents="How does AI work?",
          config=types.GenerateContentConfig(
              thinking_config=types.ThinkingConfig(
                  thinking_level=types.ThinkingLevel.LOW
              )
          ),
      )
      print(response.text)

- `MEDIUM`: **(Gemini 3 Flash, Gemini 3.1 Pro, and Gemini 3.1 Flash-Lite only)**
  Offers a balanced approach
  suitable for tasks of moderate complexity that benefit from reasoning but
  don't require deep, multi-step planning. It provides more reasoning
  capability than `LOW` while maintaining lower latency than `HIGH`:

      from google import genai
      from google.genai import types

      client = genai.Client()

      response = client.models.generate_content(
          model="gemini-3-flash-preview",
          contents="How does AI work?",
          config=types.GenerateContentConfig(
              thinking_config=types.ThinkingConfig(
                  thinking_level=types.ThinkingLevel.MEDIUM
              )
          ),
      )
      print(response.text)

- `HIGH`: Allows the model to use more tokens for thinking and is suitable for
  complex prompts requiring deep reasoning, such as multi-step planning,
  verified code generation, or advanced function calling scenarios. This is the
  default level for Gemini 3 Pro models and Gemini 3 Flash.
  Use this configuration when replacing tasks you might have previously relied
  on specialized reasoning models for:

      from google import genai
      from google.genai import types

      client = genai.Client()

      response = client.models.generate_content(
          model="gemini-3.1-pro-preview",
          contents="Find the race condition in this multi-threaded C++ snippet: [code here]",
          config=types.GenerateContentConfig(
              thinking_config=types.ThinkingConfig(
                  thinking_level=types.ThinkingLevel.HIGH
              )
          ),
      )
      print(response.text)

Thinking cannot be turned off for Gemini 3 Pro and Gemini 3.1 Pro.

If you specify both `thinking_level` and `thinking_budget` in the same request
for a Gemini 3 model, the model returns an error.

### Gemini 2.5 and earlier models

For models earlier than Gemini 3, you can control thinking using the
`thinking_budget` parameter, which sets an upper limit on the number of tokens
the model can use for its thought process. By default, if `thinking_budget` is
not set, the model automatically controls how much it thinks up to a maximum of
8,192 tokens. To use dynamic budget through the API, set `thinking_budget` to
`-1`.

You can manually set `thinking_budget` to impose a soft upper limit on the
number of tokens in situations where you might need more or less tokens than the
default thinking budget. You can set a lower token limit for less complex tasks,
or a higher limit for more complex ones. Note that this is a soft limit and therefore
there can be variability in total thought tokens. If latency is more important,
use a lower budget or set the budget to 0 to prevent thought content from being
returned with the response.

The following table shows the minimum and maximum amounts you can set the
`thinking_budget` to for each supported model:

| Model | Minimum token amount | Maximum token amount |
|---|---|---|
| Gemini 2.5 Flash | 1 | 24,576 |
| Gemini 2.5 Pro | 128 | 32,768 |
| Gemini 2.5 Flash-Lite | 512 | 24,576 |

If you set `thinking_budget` to `0` when using Gemini 2.5 Flash and
Gemini 2.5 Flash-Lite, no thought content is returned with the
response. However, reasoning-style text might still be present in the model's
output. Thinking can't be turned off for Gemini 2.5 Pro.

If you use the `thinking_level` parameter with a model earlier than Gemini 3, the
model returns an error.

### Console

1. Open [**Vertex AI Studio \> Create prompt**](https://console.cloud.google.com/vertex-ai/studio/multimodal).
2. In the **Model** panel, click **Switch model** and select one of the [supported models](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thinking#supported-models) from the menu.
3. Select **Manual** from the **Thinking budget** drop-down selector and then use the slider to adjust the thinking budget limit.

### Python

#### Install

```
pip install --upgrade google-genai
```


To learn more, see the
[SDK reference documentation](https://googleapis.github.io/python-genai/).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    from google import genai
    from google.genai.types import GenerateContentConfig, ThinkingConfig

    client = genai.Client()

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents="solve x^2 + 4x + 4 = 0",
        config=GenerateContentConfig(
            thinking_config=ThinkingConfig(
                thinking_budget=1024,  # Use `0` to turn off thinking
            )
        ),
    )

    print(response.text)
    # Example response:
    #     To solve the equation $x^2 + 4x + 4 = 0$, you can use several methods:
    #     **Method 1: Factoring**
    #     1.  Look for two numbers that multiply to the constant term (4) and add up to the coefficient of the $x$ term (4).
    #     2.  The numbers are 2 and 2 ($2 \times 2 = 4$ and $2 + 2 = 4$).
    #     ...
    #     ...
    #     All three methods yield the same solution. This quadratic equation has exactly one distinct solution (a repeated root).
    #     The solution is **x = -2**.

    # Token count for `Thinking`
    print(response.usage_metadata.thoughts_token_count)
    # Example response:
    #     886

    # Total token count
    print(response.usage_metadata.total_token_count)
    # Example response:
    #     1525

### Node.js

#### Install

```
npm install @google/genai
```


To learn more, see the
[SDK reference documentation](https://googleapis.github.io/js-genai/).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    const {GoogleGenAI} = require('@google/genai');

    const GOOGLE_CLOUD_PROJECT = process.env.GOOGLE_CLOUD_PROJECT;
    const GOOGLE_CLOUD_LOCATION = process.env.GOOGLE_CLOUD_LOCATION || 'global';

    async function generateWithThoughts(
      projectId = GOOGLE_CLOUD_PROJECT,
      location = GOOGLE_CLOUD_LOCATION
    ) {
      const client = new GoogleGenAI({
        vertexai: true,
        project: projectId,
        location: location,
      });

      const response = await client.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: 'solve x^2 + 4x + 4 = 0',
        config: {
          thinkingConfig: {
            thinkingBudget: 1024,
          },
        },
      });

      console.log(response.text);
      // Example response:
      //  To solve the equation $x^2 + 4x + 4 = 0$, you can use several methods:
      //  **Method 1: Factoring**
      //  1.  Look for two numbers that multiply to the constant term (4) and add up to the coefficient of the $x$ term (4).
      //  2.  The numbers are 2 and 2 ($2 \times 2 = 4$ and $2 + 2 = 4$).
      //  ...
      //  ...
      //  All three methods yield the same solution. This quadratic equation has exactly one distinct solution (a repeated root).
      //  The solution is **x = -2**.

      // Token count for `Thinking`
      console.log(response.usageMetadata.thoughtsTokenCount);
      // Example response:
      //  886

      // Total token count
      console.log(response.usageMetadata.totalTokenCount);
      // Example response:
      //  1525
      return response.text;
    }

### Go

Learn how to install or update the [Go](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/sdks/overview).


To learn more, see the
[SDK reference documentation](https://pkg.go.dev/google.golang.org/genai).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    import (
    	"context"
    	"fmt"
    	"io"

    	"google.golang.org/genai"
    )

    // generateThinkingBudgetContentWithText demonstrates how to generate text including the model's thought process.
    func generateThinkingBudgetContentWithText(w io.Writer) error {
    	ctx := context.Background()

    	client, err := genai.NewClient(ctx, &genai.ClientConfig{
    		HTTPOptions: genai.HTTPOptions{APIVersion: "v1"},
    	})
    	if err != nil {
    		return fmt.Errorf("failed to create genai client: %w", err)
    	}

    	modelName := "gemini-2.5-flash"
    	thinkingBudget := int32(1024) //Use `0` to turn off thinking
    	contents := []*genai.Content{
    		{
    			Parts: []*genai.Part{
    				{Text: "solve x^2 + 4x + 4 = 0"},
    			},
    			Role: "user",
    		},
    	}

    	resp, err := client.Models.GenerateContent(ctx,
    		modelName,
    		contents,
    		&genai.GenerateContentConfig{
    			ThinkingConfig: &genai.ThinkingConfig{
    				ThinkingBudget: &thinkingBudget,
    			},
    		},
    	)
    	if err != nil {
    		return fmt.Errorf("generate content failed: %w", err)
    	}

    	if resp.UsageMetadata != nil {
    		fmt.Fprintf(w, "Thoughts token count: %d\n", resp.UsageMetadata.ThoughtsTokenCount)
    		//Example response:
    		//  908
    		fmt.Fprintf(w, "Total token count: %d\n", resp.UsageMetadata.TotalTokenCount)
    		//Example response:
    		//  1364
    	}

    	fmt.Fprintln(w, resp.Text())

    	// Example response:
    	//    To solve the equation $x^2 + 4x + 4 = 0$, you can use several methods:
    	//    **Method 1: Factoring**
    	//    1.  Look for two numbers that multiply to the constant term (4) and add up to the coefficient of the $x$ term (4).
    	//    2.  The numbers are 2 and 2 ($2 \times 2 = 4$ and $2 + 2 = 4$).
    	//    ...
    	//    ...
    	//    Both methods yield the same result.
    	//    The solution to the equation $x^2 + 4x + 4 = 0$ is **$x = -2$**.

    	return nil
    }

### Java

Learn how to install or update the [Java](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/sdks/overview).


To learn more, see the
[SDK reference documentation](https://central.sonatype.com/artifact/com.google.genai/google-genai).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />


    import com.google.genai.Client;
    import com.google.genai.types.GenerateContentConfig;
    import com.google.genai.types.GenerateContentResponse;
    import com.google.genai.types.HttpOptions;
    import com.google.genai.types.ThinkingConfig;

    public class ThinkingBudgetWithTxt {

      public static void main(String[] args) {
        // TODO(developer): Replace these variables before running the sample.
        String modelId = "gemini-2.5-flash";
        generateContent(modelId);
      }

      // Generates text controlling the thinking budget
      public static String generateContent(String modelId) {
        // Initialize client that will be used to send requests. This client only needs to be created
        // once, and can be reused for multiple requests.
        try (Client client =
            Client.builder()
                .location("global")
                .vertexAI(true)
                .httpOptions(HttpOptions.builder().apiVersion("v1").build())
                .build()) {

          GenerateContentConfig contentConfig =
              GenerateContentConfig.builder()
                  .thinkingConfig(ThinkingConfig.builder().thinkingBudget(1024).build())
                  .build();

          GenerateContentResponse response =
              client.models.generateContent(modelId, "solve x^2 + 4x + 4 = 0", contentConfig);

          System.out.println(response.text());
          // Example response:
          // To solve the equation $x^2 + 4x + 4 = 0$, we can use several methods:
          //
          // **Method 1: Factoring (Recognizing a Perfect Square Trinomial)**
          //
          // Notice that the left side of the equation is a perfect square trinomial. It fits the form
          // $a^2 + 2ab + b^2 = (a+b)^2$...
          // ...
          // The solution is $x = -2$.

          response
              .usageMetadata()
              .ifPresent(
                  metadata -> {
                    System.out.println("Token count for thinking: " + metadata.thoughtsTokenCount());
                    System.out.println("Total token count: " + metadata.totalTokenCount());
                  });
          // Example response:
          // Token count for thinking: Optional[885]
          // Total token count: Optional[1468]
          return response.text();
        }
      }
    }

<br />

## View thought summaries

> [!NOTE]
>
> **Experimental
> --- Thinking**
>
>
> This feature is
>
> subject to the "Pre-GA Offerings Terms" in the General Service Terms section of the
> [Service Specific
> Terms](https://docs.cloud.google.com/terms/service-terms#1).
>
> Pre-GA features are available "as is" and might have limited support.
>
> For more information, see the
> [launch stage descriptions](https://cloud.google.com/products/#product-launch-stages).

*Thought summaries* are the abbreviated output of the thinking process that the
model went through when generating its response. You can view thought summaries
in Gemini 2.5 and newer models. To view thought
summaries, do the following:

> [!NOTE]
> **Note:** Thought summarization is a best-effort feature. You aren't guaranteed to receive the `thoughts` section in the API response even if you set `include_thoughts=True`.

### Console


Thought summaries are enabled by default in Vertex AI Studio.
You can see the model's summarized thought process by expanding the
**Thoughts** panel.

### Python

#### Install

```
pip install --upgrade google-genai
```


To learn more, see the
[SDK reference documentation](https://googleapis.github.io/python-genai/).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    from google import genai
    from google.genai.types import GenerateContentConfig, ThinkingConfig

    client = genai.Client()
    response = client.models.generate_content(
        model="gemini-2.5-pro",
        contents="solve x^2 + 4x + 4 = 0",
        config=GenerateContentConfig(
            thinking_config=ThinkingConfig(include_thoughts=True)
        ),
    )

    print(response.text)
    # Example Response:
    #     Okay, let's solve the quadratic equation x² + 4x + 4 = 0.
    #     ...
    #     **Answer:**
    #     The solution to the equation x² + 4x + 4 = 0 is x = -2. This is a repeated root (or a root with multiplicity 2).

    for part in response.candidates[0].content.parts:
        if part and part.thought:  # show thoughts
            print(part.text)
    # Example Response:
    #     **My Thought Process for Solving the Quadratic Equation**
    #
    #     Alright, let's break down this quadratic, x² + 4x + 4 = 0. First things first:
    #     it's a quadratic; the x² term gives it away, and we know the general form is
    #     ax² + bx + c = 0.
    #
    #     So, let's identify the coefficients: a = 1, b = 4, and c = 4. Now, what's the
    #     most efficient path to the solution? My gut tells me to try factoring; it's
    #     often the fastest route if it works. If that fails, I'll default to the quadratic
    #     formula, which is foolproof. Completing the square? It's good for deriving the
    #     formula or when factoring is difficult, but not usually my first choice for
    #     direct solving, but it can't hurt to keep it as an option.
    #
    #     Factoring, then. I need to find two numbers that multiply to 'c' (4) and add
    #     up to 'b' (4). Let's see... 1 and 4 don't work (add up to 5). 2 and 2? Bingo!
    #     They multiply to 4 and add up to 4. This means I can rewrite the equation as
    #     (x + 2)(x + 2) = 0, or more concisely, (x + 2)² = 0. Solving for x is now
    #     trivial: x + 2 = 0, thus x = -2.
    #
    #     Okay, just to be absolutely certain, I'll run the quadratic formula just to
    #     double-check. x = [-b ± √(b² - 4ac)] / 2a. Plugging in the values, x = [-4 ±
    #     √(4² - 4 * 1 * 4)] / (2 * 1). That simplifies to x = [-4 ± √0] / 2. So, x =
    #     -2 again -- a repeated root. Nice.
    #
    #     Now, let's check via completing the square. Starting from the same equation,
    #     (x² + 4x) = -4. Take half of the b-value (4/2 = 2), square it (2² = 4), and
    #     add it to both sides, so x² + 4x + 4 = -4 + 4. Which simplifies into (x + 2)²
    #     = 0. The square root on both sides gives us x + 2 = 0, therefore x = -2, as
    #      expected.
    #
    #     Always, *always* confirm! Let's substitute x = -2 back into the original
    #     equation: (-2)² + 4(-2) + 4 = 0. That's 4 - 8 + 4 = 0. It checks out.
    #
    #     Conclusion: the solution is x = -2. Confirmed.

### Node.js

#### Install

```
npm install @google/genai
```


To learn more, see the
[SDK reference documentation](https://googleapis.github.io/js-genai/).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    const {GoogleGenAI} = require('@google/genai');

    const GOOGLE_CLOUD_PROJECT = process.env.GOOGLE_CLOUD_PROJECT;
    const GOOGLE_CLOUD_LOCATION = process.env.GOOGLE_CLOUD_LOCATION || 'global';

    async function generateWithThoughts(
      projectId = GOOGLE_CLOUD_PROJECT,
      location = GOOGLE_CLOUD_LOCATION
    ) {
      const client = new GoogleGenAI({
        vertexai: true,
        project: projectId,
        location: location,
      });

      const response = await client.models.generateContent({
        model: 'gemini-2.5-pro',
        contents: 'solve x^2 + 4x + 4 = 0',
        config: {
          thinkingConfig: {
            includeThoughts: true,
          },
        },
      });

      console.log(response.text);
      // Example Response:
      //  Okay, let's solve the quadratic equation x² + 4x + 4 = 0.
      //  ...
      //  **Answer:**
      //  The solution to the equation x² + 4x + 4 = 0 is x = -2. This is a repeated root (or a root with multiplicity 2).

      for (const part of response.candidates[0].content.parts) {
        if (part && part.thought) {
          console.log(part.text);
        }
      }

      // Example Response:
      // **My Thought Process for Solving the Quadratic Equation**
      //
      // Alright, let's break down this quadratic, x² + 4x + 4 = 0. First things first:
      // it's a quadratic; the x² term gives it away, and we know the general form is
      // ax² + bx + c = 0.
      //
      // So, let's identify the coefficients: a = 1, b = 4, and c = 4. Now, what's the
      // most efficient path to the solution? My gut tells me to try factoring; it's
      // often the fastest route if it works. If that fails, I'll default to the quadratic
      // formula, which is foolproof. Completing the square? It's good for deriving the
      // formula or when factoring is difficult, but not usually my first choice for
      // direct solving, but it can't hurt to keep it as an option.
      //
      // Factoring, then. I need to find two numbers that multiply to 'c' (4) and add
      // up to 'b' (4). Let's see... 1 and 4 don't work (add up to 5). 2 and 2? Bingo!
      // They multiply to 4 and add up to 4. This means I can rewrite the equation as
      // (x + 2)(x + 2) = 0, or more concisely, (x + 2)² = 0. Solving for x is now
      // trivial: x + 2 = 0, thus x = -2.
      //
      // Okay, just to be absolutely certain, I'll run the quadratic formula just to
      // double-check. x = [-b ± √(b² - 4ac)] / 2a. Plugging in the values, x = [-4 ±
      // √(4² - 4 * 1 * 4)] / (2 * 1). That simplifies to x = [-4 ± √0] / 2. So, x =
      // -2 again -- a repeated root. Nice.
      //
      // Now, let's check via completing the square. Starting from the same equation,
      // (x² + 4x) = -4. Take half of the b-value (4/2 = 2), square it (2² = 4), and
      // add it to both sides, so x² + 4x + 4 = -4 + 4. Which simplifies into (x + 2)²
      // = 0. The square root on both sides gives us x + 2 = 0, therefore x = -2, as
      //  expected.
      //
      // Always, *always* confirm! Let's substitute x = -2 back into the original
      // equation: (-2)² + 4(-2) + 4 = 0. That's 4 - 8 + 4 = 0. It checks out.
      //
      // Conclusion: the solution is x = -2. Confirmed.

      return response.text;
    }

### Go

Learn how to install or update the [Go](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/sdks/overview).


To learn more, see the
[SDK reference documentation](https://pkg.go.dev/google.golang.org/genai).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />

    import (
    	"context"
    	"fmt"
    	"io"

    	"google.golang.org/genai"
    )

    // generateContentWithThoughts demonstrates how to generate text including the model's thought process.
    func generateContentWithThoughts(w io.Writer) error {
    	ctx := context.Background()

    	client, err := genai.NewClient(ctx, &genai.ClientConfig{
    		HTTPOptions: genai.HTTPOptions{APIVersion: "v1"},
    	})
    	if err != nil {
    		return fmt.Errorf("failed to create genai client: %w", err)
    	}

    	modelName := "gemini-2.5-pro"
    	contents := []*genai.Content{
    		{
    			Parts: []*genai.Part{
    				{Text: "solve x^2 + 4x + 4 = 0"},
    			},
    			Role: "user",
    		},
    	}

    	resp, err := client.Models.GenerateContent(ctx,
    		modelName,
    		contents,
    		&genai.GenerateContentConfig{
    			ThinkingConfig: &genai.ThinkingConfig{
    				IncludeThoughts: true,
    			},
    		},
    	)
    	if err != nil {
    		return fmt.Errorf("failed to generate content: %w", err)
    	}

    	if len(resp.Candidates) == 0 || resp.Candidates[0].Content == nil {
    		return fmt.Errorf("no content was generated")
    	}

    	// The response may contain both the final answer and the model's thoughts.
    	// Iterate through the parts to print them separately.
    	fmt.Fprintln(w, "Answer:")
    	for _, part := range resp.Candidates[0].Content.Parts {
    		if part.Text != "" && !part.Thought {
    			fmt.Fprintln(w, part.Text)
    		}
    	}
    	fmt.Fprintln(w, "\nThoughts:")
    	for _, part := range resp.Candidates[0].Content.Parts {
    		if part.Thought {
    			fmt.Fprintln(w, part.Text)
    		}
    	}

    	// Example response:
    	//  Answer:
    	//	Of course! We can solve this quadratic equation in a couple of ways.
    	//
    	//### Method 1: Factoring (the easiest method for this problem)
    	//
    	//1.  **Recognize the pattern.** The expression `x² + 4x + 4` is a perfect square trinomial. It fits the pattern `a² + 2ab + b² = (a + b)²`. In this case, `a = x` and `b = 2`.
    	//
    	//2.  **Factor the equation.**
    	//    `x² + 4x + 4 = (x + 2)(x + 2) = (x + 2)²`
    	//
    	//3.  **Solve for x.** Now set the factored expression to zero:
    	//    `(x + 2)² = 0`
    	//
    	//    Take the square root of both sides:
    	//    `x + 2 = 0`
    	//
    	//    Subtract 2 from both sides:
    	//    `x = -2`
    	//
    	//This type of solution is called a "repeated root" or a "double root" because the factor `(x+2)` appears twice.
    	//
    	//---
    	//
    	//### Method 2: Using the Quadratic Formula
    	//
    	//You can use the quadratic formula for any equation in the form `ax² + bx + c = 0`.
    	//
    	//The formula is: `x = [-b ± sqrt(b² - 4ac)] / 2a`
    	//
    	//1.  **Identify a, b, and c.**
    	//    *   a = 1
    	//    *   b = 4
    	//    *   c = 4
    	//
    	//2.  **Plug the values into the formula.**
    	//    `x = [-4 ± sqrt(4² - 4 * 1 * 4)] / (2 * 1)`
    	//
    	//3.  **Simplify.**
    	//    `x = [-4 ± sqrt(16 - 16)] / 2`
    	//    `x = [-4 ± sqrt(0)] / 2`
    	//    `x = -4 / 2`
    	//
    	//4.  **Solve for x.**
    	//    `x = -2`
    	//Alright, the user wants to solve the quadratic equation `x² + 4x + 4 = 0`. My first instinct is to see if I can factor it; that's often the fastest approach if it works.  Looking at the coefficients, I see `a = 1`, `b = 4`, and `c = 4`.  Factoring is clearly the most direct path here. I need to find two numbers that multiply to 4 (c) and add up to 4 (b). Hmm, let's see... 1 and 4? Nope, that adds to 5.  2 and 2? Perfect!  2 times 2 is 4, and 2 plus 2 is also 4.
    	//
    	//So, `x² + 4x + 4` factors nicely into `(x + 2)(x + 2)`.  Ah, a perfect square trinomial! That's useful to note. Now, I can write the equation as `(x + 2)² = 0`.  Taking the square root of both sides gives me `x + 2 = 0`.  And finally, subtracting 2 from both sides, I get `x = -2`.  That's the solution.
    	//
    	//Just to be thorough, and maybe to offer an alternative explanation, let's verify this using the quadratic formula. It's `x = [-b ± √(b² - 4ac)] / 2a`. Plugging in my values:  `x = [-4 ± √(4² - 4 * 1 * 4)] / (2 * 1)`.  That simplifies to `x = [-4 ± √(16 - 16)] / 2`, or `x = [-4 ± 0] / 2`.  Therefore, `x = -2`. The discriminant being zero tells me I have exactly one real, repeated root.  Great. So, whether I factor or use the quadratic formula, the answer is the same.
    	return nil
    }

### Java

Learn how to install or update the [Java](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/sdks/overview).


To learn more, see the
[SDK reference documentation](https://central.sonatype.com/artifact/com.google.genai/google-genai).


Set environment variables to use the Gen AI SDK with Vertex AI:

```bash
# Replace the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_LOCATION` values
# with appropriate values for your project.
export GOOGLE_CLOUD_PROJECT=GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_LOCATION=global
export GOOGLE_GENAI_USE_VERTEXAI=True
```

<br />


    import com.google.genai.Client;
    import com.google.genai.types.Candidate;
    import com.google.genai.types.Content;
    import com.google.genai.types.GenerateContentConfig;
    import com.google.genai.types.GenerateContentResponse;
    import com.google.genai.types.HttpOptions;
    import com.google.genai.types.ThinkingConfig;

    public class ThinkingIncludeThoughtsWithTxt {

      public static void main(String[] args) {
        // TODO(developer): Replace these variables before running the sample.
        String modelId = "gemini-2.5-pro";
        generateContent(modelId);
      }

      // Generates text including thoughts in the response
      public static String generateContent(String modelId) {
        // Initialize client that will be used to send requests. This client only needs to be created
        // once, and can be reused for multiple requests.
        try (Client client =
            Client.builder()
                .location("global")
                .vertexAI(true)
                .httpOptions(HttpOptions.builder().apiVersion("v1").build())
                .build()) {

          GenerateContentConfig contentConfig =
              GenerateContentConfig.builder()
                  .thinkingConfig(ThinkingConfig.builder().includeThoughts(true).build())
                  .build();

          GenerateContentResponse response =
              client.models.generateContent(modelId, "solve x^2 + 4x + 4 = 0", contentConfig);

          System.out.println(response.text());
          // Example response:
          // We can solve the equation x² + 4x + 4 = 0 using a couple of common methods.
          //
          // ### Method 1: Factoring (The Easiest Method for this Problem)
          // **Recognize the pattern:** The pattern for a perfect square trinomial
          // is a² + 2ab + b² = (a + b)².
          // ...
          // ### Final Answer:
          // The solution is **x = -2**.

          // Get parts of the response and print thoughts
          response
              .candidates()
              .flatMap(candidates -> candidates.stream().findFirst())
              .flatMap(Candidate::content)
              .flatMap(Content::parts)
              .ifPresent(
                  parts -> {
                    parts.forEach(
                        part -> {
                          if (part.thought().orElse(false)) {
                            part.text().ifPresent(System.out::println);
                          }
                        });
                  });
          // Example response:
          // Alright, let's break down this quadratic equation, x² + 4x + 4 = 0. My initial thought is,
          // "classic quadratic."  I'll need to find the values of 'x' that make this equation true. The
          // equation is in standard form, and since the coefficients are relatively small, I
          // immediately suspect that factoring might be the easiest route.  It's worth checking.
          //
          // First, I assessed what I had. *a* is 1, *b* is 4, and *c* is 4. I consider my toolkit.
          // Factoring is the likely first choice, then I can use the quadratic formula as a backup,
          // because that ALWAYS works, and I could use graphing. However, for this, factoring seems the
          // cleanest approach.
          //
          // Okay, factoring. I need two numbers that multiply to *c* (which is 4) and add up to *b*
          // (also 4).  I quickly run through the factor pairs of 4: (1, 4), (-1, -4), (2, 2), (-2, -2).
          //  Aha! 2 and 2 fit the bill. They multiply to 4 *and* add up to 4.  Therefore, I can rewrite
          // the equation as (x + 2)(x + 2) = 0.  That simplifies to (x + 2)² = 0. Perfect square
          // trinomial -- nice and tidy. Seeing that pattern from the outset can save a step or two. Now,
          // to solve for *x*:  if (x + 2)² = 0, then x + 2 must equal 0.  Therefore, x = -2. Done.
          //
          // But, for the sake of a full explanation, let's use the quadratic formula as a second
          // method. It's a reliable way to double-check the answer, plus it's good practice.  I plug my
          // *a*, *b*, and *c* values into the formula: x = [-b ± √(b² - 4ac)] / (2a). That gives me  x
          // = [-4 ± √(4² - 4 * 1 * 4)] / (2 * 1). Simplifying under the radical, I get x = [-4 ± √(16 -
          // 16)] / 2. So, x = [-4 ± √0] / 2. The square root of 0 is zero, which is very telling!  When
          // the discriminant (b² - 4ac) is zero, you get one real solution, a repeated root. This means
          // x = -4 / 2, which simplifies to x = -2.  Exactly the same as before.
          //
          // Therefore, the answer is x = -2.  Factoring was the most straightforward route.  For
          // completeness, I showed the solution via the quadratic formula, too. Both approaches lead to
          // the same single solution.  This is a repeated root -- a double root, if you will.
          //
          // And to be absolutely sure...let's check our answer! Substitute -2 back into the original
          // equation. (-2)² + 4(-2) + 4 = 4 - 8 + 4 = 0.  Yep, 0 = 0. The solution is correct.
          return response.text();
        }
      }
    }

<br />

## Thought signatures

Thought signatures are encrypted representations of the model's internal thought
process that preserve the Gemini reasoning state during multi-turn
conversations, especially when using [function
calling](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/function-calling).

To ensure the model maintains full context across multiple turns of a
conversation, you must return the thought signatures from previous responses in
your subsequent requests, regardless of the thinking level used. If you are
using the official Google Gen AI SDK (Python, Node.js, Go, or
Java) and using the standard chat history features or appending the full model
response to the history, thought signatures are handled automatically.

For more information, see [Thought signatures](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thought-signatures).

## Prompting techniques

Effective prompting is crucial for maximizing the benefits of the
Gemini thinking models. This section outlines some prompting practices
for thinking models.

Begin with general instructions that describe the preferred outcome. Start with a
low-complexity prompt and observe the model's initial thoughts on how to respond.

|---|
| **Prompt:** ``` Describe the most unusual or striking architectural feature you've ever seen in a building or structure. ``` **Response:** ``` <...> The most unusual architectural feature that has truly stayed with me is the "floating roof" of the Heydar Aliyev Center in Baku, Azerbaijan, designed by Zaha Hadid Architects. Visually, it's breathtaking. Imagine a vast, undulating landscape of pure white, seemingly draped over the building. It's not just a roof in the traditional sense; it's an extension of the ground, flowing seamlessly upwards and over the building's various spaces before curving back down to meet the earth again. There are no sharp angles, no rigid lines. Instead, everything is fluid, organic, and continuous. It resembles a giant, pristine white wave frozen in motion, or perhaps a sand dune sculpted by an unseen wind. <...> ``` (gemini-2.5-pro-exp-03-25) |

### Provide step-by-step instructions

If the initial attempt does not yield the expected result, refine your prompt by
providing more explicit step-by-step instructions to guide Gemini
through the problem-solving process for a more focused approach. This allows you
steer the model's initial understanding of the task with explicit suggestions
and guidance.

|---|
| **Prompt:** ``` Now imagine that architectural feature is not just for looks, but has a specific function or purpose related to the building's environment or the people who use it. Explain what that function could be and how it enhances the building's overall design and usability. ``` **Response:** ``` <...> Let's imagine that the "floating roof" of the Heydar Aliyev Center is not purely aesthetic but serves a crucial environmental and user-centric function: it's designed as a sophisticated climate moderator and natural ventilation system for the Baku environment. Here's how this function would work and enhance the building: Function: Passive Climate Control and Natural Ventilation System Shading and Solar Heat Mitigation: The undulating curves of the white GFRC roof are strategically shaped and oriented to provide optimal shading throughout the day, year-round. Baku experiences intense sun, especially during the summer. The overhanging curves, acting like giant brise-soleils, would block direct sunlight from hitting the building's glass facade, significantly reducing solar heat gain. The varying heights and depths of the curves would create dynamic shade patterns, ensuring that different parts of the building are shaded at different times of the day, optimizing comfort and reducing the need for excessive air conditioning. The white color of the GFRC further enhances this by reflecting a large portion of the solar radiation. <...> ``` (gemini-2.5-pro-exp-03-25) |

### Multishot prompting with thinking

Multishot prompting in conjunction with thinking can further enhance
Gemini's understanding and improve the accuracy of its responses.
Provide several examples of input-output pairs, demonstrating the preferred
behavior and output format in your prompt.

|---|
| **Prompt:** ``` Example 1: User: What is the tallest mountain in the world? Assistant: Mount Everest Example 2: User: What is the largest ocean? Assistant: Pacific Ocean User: What is the longest river in the world? Assistant: ``` **Response:** ``` Amazon River ``` (gemini-2.5-pro-exp-03-25) |

### Defining output and behavior

When building an application where users will interact directly with the model,
you may want to provide guidance for how Gemini's output and responses
will sound and be formatted.

#### System instructions

System instructions are a set of instructions that the model processes before it
processes prompts. They are recalled each time the model is prompted and tell
the model how you want it to behave and respond. For example, you can include
things like the role or persona, contextual information, and formatting
instructions.

|---|
| **Prompt:** ``` System Instruction: You are a helpful and concise coding tutor. Always provide code examples and explain them briefly. User Prompt: Explain what is a closure in Javascript and give an example. ``` **Response:** ``` function outerFunction(outerVar) { function innerFunction(innerVar) { console.log(outerVar); // Accessing outerVar from outerFunction's scope console.log(innerVar); } return innerFunction; } const closureExample = outerFunction('I am from outer'); closureExample('I am from inner'); Explanation: A closure is created when a function (innerFunction in this example) is defined inside another function (outerFunction) and the inner function remembers and has access to the variables from the outer function's scope, even after the outer function has finished executing. In the example: outerFunction is called with 'I am from outer' and returns innerFunction. closureExample now holds a reference to innerFunction. When closureExample('I am from inner') is called, innerFunction executes. Even though outerFunction has already finished, innerFunction can still access and use outerVar (which is 'I am from outer') because of the closure. In essence, the innerFunction "closes over" the variables of its outer function's scope, creating a closure. ``` (gemini-2.5-pro-exp-03-25) |

#### Verification and reflection

Include specific verification steps in either the system instructions or your
prompts directly. For example, ask Gemini to verify its sources, review
its reasoning, identify potential errors, and check its final answer.

|---|
| **Prompt:** ``` Verify the following statement and provide your sources: The capital of Brazil is Rio de Janeiro. ``` **Response:** ``` The statement "The capital of Brazil is Rio de Janeiro" is incorrect. The current capital of Brazil is Brasília. Rio de Janeiro was the capital of Brazil for a significant period, from 1763 to 1960. However, the capital was moved to Brasília in 1960 as part of a plan to develop the country's interior and create a more centrally located capital. Verification and Sources: You can easily verify this information from numerous reliable sources: Encyclopedias: Britannica: Searching for "Brazil" on Britannica will clearly state Brasília as the capital. https://www.britannica.com/place/Brazil (Look for the "Capital" information in the introductory summary or "Geography" section) Wikipedia: The Wikipedia article for "Brazil" also states Brasília as the capital. https://en.wikipedia.org/wiki/Brazil (Look in the infobox or introductory section) Government and Official Sources: CIA World Factbook: This is a highly reliable source for country information. Searching for "Brazil" will list Brasília as the capital. https://www.cia.gov/the-world-factbook/countries/brazil/ (Look under "Government" > "Capital") Official Website of the Brazilian Government (if accessible and in English): While navigating official government websites can sometimes be complex, they would definitively list Brasília as the capital. Geographic Resources: National Geographic: Their website and publications will confirm Brasília as the capital of Brazil. Atlases and Geography Textbooks: Any modern atlas or geography textbook will list Brasília as the capital. Why the confusion? The confusion might arise because: Rio de Janeiro is a very famous Brazilian city: It's a major tourist destination, known for its beaches, Carnival, and iconic landmarks like Christ the Redeemer. Its past status as capital adds to its historical significance and public recognition. Historical context: Rio de Janeiro was the capital for a long time. People who learned about Brazil in the past might remember it as the capital. In conclusion, the statement is false. The capital of Brazil is Brasília, not Rio de Janeiro. Rio de Janeiro was the former capital but is no longer the current capital. You can confidently use the sources listed above to verify this information. ``` (gemini-2.5-pro-exp-03-25) |

### Debugging and steering

Vertex AI Studio provides developers access to the model's thoughts in
the UI. This is helpful as a developer reviewing your prompt when debugging:

#### Analyze the thought process

Carefully review Gemini's thought process to identify any areas where
it may have gone astray. This analysis can provide valuable clues for refining
your prompts and getting your expected response consistently in your
application.

*Example Scenario: If Gemini's thought process shows it misunderstood a step in
a complex instruction, you can refine the prompt to clarify that specific step.*

|---|
| **Prompt:** ``` Step 1: Summarize the following article about quantum physics. Step 2: Translate the summary into Spanish. Step 3: Extract the key entities from the Spanish summary. Article: ... [Article Text] ... ``` **Gemini's Thought Process Analysis (Example):** ``` The user wants me to process an article about Google's new quantum chip called Willow in three steps: Step 1: Summarize the article. Step 2: Translate the summary into Spanish. Step 3: Extract the key entities from the Spanish summary. Let's break down each step. Step 1: Summarize the article. I need to read the article and identify the main points. The article is about Google's new quantum chip, Willow, and its achievements. The key achievements are: Exponential error reduction as qubits scale up. Outperforming supercomputers in a benchmark computation (RCS). Willow is a step towards commercially relevant quantum computing. It's the first system below threshold for quantum error correction. It achieved a benchmark computation in under 5 minutes that would take a supercomputer 10 septillion years. It was fabricated in a new facility. It has state-of-the-art performance and high quality qubits. Google is looking towards real-world applications with Willow. Quantum computing will benefit AI. I will synthesize these points into a concise summary. Step 2: Translate the summary into Spanish. Once I have the summary in English, I will translate it into Spanish. I need to ensure the translation is accurate and natural-sounding in Spanish. Step 3: Extract the key entities from the Spanish summary. After translating the summary, I will identify and extract the key entities. Key entities are typically nouns or noun phrases that represent important objects, concepts, or actors. In this context, they will likely include: Names of chips (Willow, Sycamore) Companies/Organizations (Google Quantum AI, Google Research) Technologies (quantum chip, quantum computer, qubits, quantum error correction, superconducting quantum system, classical computers, supercomputers, AI) Benchmarks (random circuit sampling, RCS) People (Julian Kelly, Peter Shor, David Deutsch, Sergio Boixo, Hartmut Neven, John Preskill) Concepts (exponential error reduction, below threshold, beyond breakeven, state-of-the-art performance, commercially relevant applications, quantum mechanics, multiverse, T1 times, system benchmarks, algorithmic benchmarks) I will need to carefully review the Spanish summary to identify these entities and list them out. ``` |

#### Provide corrective feedback

If you observe errors or inconsistencies in Gemini's reasoning, provide
corrective feedback in your prompt and the system instructions to anticipate
where the model's response may deviate from your desired outcome.

|---|
| **Prompt:** ``` You are an expert in botany. When asked to identify a plant, focus on leaf shape, flower structure, and stem characteristics. Identify this plant based on these characteristics: ... [Plant Characteristics Description] ... Previous incorrect response focused on habitat only. Please disregard habitat and focus on morphology. ``` **Refined Prompt (if needed based on thought process):** ``` Previous incorrect response focused on habitat only. Please disregard habitat and focus on morphology. ``` **Response:** ``` Tabebuia vellosoi ``` (gemini-2.5-pro-exp-03-25) |

### Making the best of long outputs and long-form thinking

Thinking generates "thoughts" as part of the Token Output that showcases
Gemini's detailed reasoning. To make the most of these outputs:

#### Review the reasoning

Pay close attention to Gemini's reasoning process (available in the
Vertex AI Studio UI), how it broke down the task and the choices it
made for your output. This can help you understand how it arrived at its
conclusion.

#### Provide guidance in reasoning

If you want your output to be particularly lengthy, you may want to provide more
guidance in your prompt to constrain the amount of thinking needed to accomplish
the task presented in the prompt. This lets you reserve more of the token output
for your response.

\**Example: For a detailed report, you might specify sections and subsections in
your prompt to guide Gemini's thinking and structure the output efficiently.*

|---|
| **Prompt:** ``` Generate a detailed report on the impact of climate change on coastal ecosystems. Report Structure: Introduction Rising Sea Levels 2.1. Impact on Mangroves 2.2. Impact on Coral Reefs Ocean Acidification 3.1. Impact on Shellfish 3.2. Impact on Plankton Extreme Weather Events 4.1. Increased Storm Intensity 4.2. Coastal Erosion Conclusion Provide detailed analysis within each section. ``` **Response:** ``` <...> Climate Change Impact on Coastal Ecosystems: A Detailed Report 1.  Introduction Coastal ecosystems, the dynamic interface between land and sea, are among the most productive and biodiverse environments on Earth. They provide crucial ecosystem services, including coastal protection, fisheries, carbon sequestration, and support for a vast array of species. However, these vital ecosystems are increasingly threatened by the multifaceted impacts of climate change. Driven by anthropogenic greenhouse gas emissions, climate change is manifesting in several interconnected ways that are profoundly altering the physical and chemical conditions of coastal environments. This report will delve into the key impacts of climate change on coastal ecosystems, focusing on rising sea levels, ocean acidification, and extreme weather events, and their specific consequences for critical habitats like mangroves and coral reefs, and key organisms like shellfish and plankton. Understanding these impacts is crucial for developing effective conservation and management strategies to mitigate the damage and enhance the resilience of these invaluable ecosystems. 2.  Rising Sea Levels Rising sea levels are a direct and significant consequence of global warming, driven by thermal expansion of seawater and the melting of land ice (glaciers and ice sheets). This phenomenon poses a direct threat to low-lying coastal ecosystems by inundating habitats, altering salinity regimes, and increasing erosion rates. The rate of sea level rise is accelerating, and projections for the 21st century indicate a continued upward trend, with potentially devastating consequences for coastal environments. 2.1. Impact on Mangroves Mangrove forests are unique coastal ecosystems found in tropical and subtropical intertidal zones. They provide numerous benefits, including coastal protection against storms, nursery grounds for fish and invertebrates, and significant carbon sequestration... <...> ``` (gemini-2.5-pro-exp-03-25) |

## Pricing

You are charged for the tokens that are generated during a model's thinking
process. For some models, such as Gemini 3 Pro and
Gemini 2.5 Pro, thinking is enabled by
default and you are billed for these tokens.

For more information, see [Vertex AI pricing](https://docs.cloud.google.com/vertex-ai/generative-ai/pricing).
To learn how to manage costs, see [Control the thinking budget](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thinking#budget).

## What's next

Notebook

### [Intro to Gemini 2.5 Flash](https://github.com/GoogleCloudPlatform/generative-ai/blob/main/gemini/getting-started/intro_gemini_2_5_flash.ipynb)


Use Gemini 2.5 Flash to explore features like Thinking, tokenization, and code execution in this Colab notebook.

Console

### [Google Cloud Console](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/vertex-ai/studio/multimodal?model=gemini-2.5-flash)


Try prompting Gemini for yourself in the Google Cloud Console.

Guide

### [Thought signatures](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thought-signatures)


Learn how to preserve the Gemini reasoning state during multi-turn and multi-step conversations using thought signatures.