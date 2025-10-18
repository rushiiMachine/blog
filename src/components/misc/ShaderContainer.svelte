<script lang="ts">
/** biome-ignore-all lint/style/noNonNullAssertion: ignore */

import { onMount } from "svelte";

interface Props {
	fragmentShader: string;
	followReducedAnimation?: boolean;
	class?: string;
}

let {
	fragmentShader,
	followReducedAnimation: followReducedMotion = true,
	class: className,
}: Props = $props();

let canvas: HTMLCanvasElement;

onMount(() => {
	let cancel = false;
	let gl: WebGLRenderingContext;
	let u_resolution: WebGLUniformLocation;
	let u_time: WebGLUniformLocation;

	if (
		followReducedMotion &&
		window.matchMedia("(prefers-reduced-motion: reduce)").matches
	) {
		return;
	}

	// Make internal canvas size match element size
	canvas.width = canvas.offsetWidth;
	canvas.height = canvas.offsetHeight;

	function init() {
		gl = canvas.getContext("webgl")!;

		if (!gl) {
			console.error("WebGL is not supported in this environment!");
			canvas.remove();
			return;
		}

		const vertexShader = gl.createShader(gl.VERTEX_SHADER)!;
		gl.shaderSource(
			vertexShader,
			`
            attribute vec2 a_position;

            void main() {
                gl_Position = vec4(a_position, 0., 1.);
            }
        `,
		);
		gl.compileShader(vertexShader);
		if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
			console.error(gl.getShaderInfoLog(vertexShader));
			return;
		}

		const fragShader = gl.createShader(gl.FRAGMENT_SHADER)!;
		gl.shaderSource(fragShader, fragmentShader);
		gl.compileShader(fragShader);
		if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
			console.error(gl.getShaderInfoLog(fragShader));
			return;
		}

		const program = gl.createProgram();
		gl.attachShader(program, fragShader);
		gl.attachShader(program, vertexShader);
		gl.linkProgram(program);
		gl.useProgram(program);

		const positions = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0];
		const positionBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

		const a_position = gl.getAttribLocation(program, "a_position");
		gl.enableVertexAttribArray(a_position);
		gl.vertexAttribPointer(a_position, 2, gl.FLOAT, false, 0, 0);

		u_resolution = gl.getUniformLocation(program, "u_resolution")!;
		u_time = gl.getUniformLocation(program, "u_time")!;

		gl.clearColor(0.0, 0.0, 0.0, 1.0); // Set fully black and opaque
		gl.clear(gl.COLOR_BUFFER_BIT);
	}

	let frame = requestAnimationFrame(() => {
		init();
		canvas.setAttribute("style", "opacity: unset");
		frame = requestAnimationFrame(function loop(time) {
			if (cancel) return;
			frame = requestAnimationFrame(loop);

			gl.uniform2f(u_resolution, canvas.width, canvas.height);
			gl.uniform1f(u_time, time / 1000.0);
			gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		});
	});

	return () => {
		cancel = true;
	};
});
</script>

<canvas bind:this={canvas} class={["opacity-0 transition-opacity duration-1000", className]}></canvas>
